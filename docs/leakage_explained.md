# 누설점 — 한 걸음씩 이해하기

이 문서는 이 프로젝트를 처음 보는 사람에게 **"FPGA 어디서 비밀이 새는가"** 를
배경부터 차근차근 설명합니다. 부채널 공격을 처음 들어보는 분도 따라올 수 있도록
일상적 비유와 그림을 많이 사용했습니다.

목차:
1. [이 프로젝트가 뭐 하는 건가](#1-이-프로젝트가-뭐-하는-건가)
2. [부채널 공격이 뭔지](#2-부채널-공격이-뭔지)
3. [PQC와 NTT butterfly](#3-pqc와-ntt-butterfly)
4. [FPGA 파이프라인이 어떻게 굴러가는가](#4-fpga-파이프라인이-어떻게-굴러가는가)
5. [register가 누설하는 물리적 이유](#5-register가-누설하는-물리적-이유)
6. [이 디자인의 누설점 — 단계별 그림](#6-이-디자인의-누설점--단계별-그림)
7. [세 가지 증거](#7-세-가지-증거)
8. [숫자로 직접 보기](#8-숫자로-직접-보기)
9. [의미와 대응책](#9-의미와-대응책)

---

## 1. 이 프로젝트가 뭐 하는 건가

### 큰 그림

> **"우리가 만든 PQC 하드웨어 가속기가 비밀을 새고 있는지 측정하는 실험실."**

세 부품으로 구성됩니다:

```
┌─────────┐    USB    ┌──────────────┐                ┌─────────────┐
│   PC    │ ────────▶ │ CW305 보드  │                │ Husky-Plus  │
│         │           │ (FPGA + USB) │                │   (scope)   │
│ Python  │ ◀──────── │              │                │             │
│ 스크립트 │   결과     │  butterfly   │                │  ADC 192MHz │
└─────────┘           │  계산 수행   │                │             │
                      │              │ 20-pin connector│             │
                      │  tio_trigger ├────────────────┤ tio4 (입력) │
                      │  tio_clkout  ├────────────────┤ extclk      │
                      │              │                │             │
                      │  Vcc-int     │ SMA cable      │             │
                      │  power tap   ├────────────────┤ measure SMA │
                      │              │                │             │
                      └──────────────┘                └─────────────┘
```

**역할 분담**:
- **PC**: 입력 (a, b, k, mode 등) 을 USB로 FPGA에 보내고, 결과를 받아옴
- **CW305 (FPGA 보드)**: butterfly 계산을 실제 회로로 수행. 동시에 측정 가능한
  trigger 신호와 clock 신호를 외부 핀으로 노출
- **Husky-Plus (측정 장비)**: trigger가 올라가는 순간부터 ADC로 192 MHz로 sampling
  하면서 FPGA의 전원선 전압 변동을 기록

**왜 이런 셋업이냐**: FPGA 내부에서 무엇을 계산하는지는 우리가 다 압니다 (RTL 코드를
우리가 짰으니). 그런데 **외부에서 전력만 측정해도 비밀이 보이는지** 가 알고 싶은
질문. 그래서 측정 환경을 정밀하게 만들어 놓고 검증.

---

## 2. 부채널 공격이 뭔지

### 일상 비유: 도어락 비밀번호 듣기

문 도어락에 비밀번호 입력하는 모습을 상상해보세요. 누군가 옆에서 화면은 안 보지만,
**버튼 눌리는 소리**만 듣고 있다고 합시다.

- "삑..삑..삑..삑" — 일정한 간격으로 4번 → 비밀번호 길이 4
- 어떤 버튼은 더 큰 소리, 어떤 건 작은 소리 → 어쩌면 누른 위치 추정 가능
- 누르고 다음 누르기까지 시간이 길면 → 손가락 멀리 이동 (예: 1번 → 9번)

이게 부채널의 핵심 아이디어. **메인 채널 (도어락 화면, 출입 결과)** 이 아닌,
**부수적 채널 (소리, 시간)** 으로도 정보가 새어나가요.

### 컴퓨터 칩에서

칩이 "1을 0으로 바꾸려면" 트랜지스터 하나가 짧은 순간 **전류를 끌어다 씁니다**.
0을 1로 바꿀 때도 마찬가지. 비트가 하나도 안 바뀌는 사이클은 전력이 거의 안 들어가
요. 비트가 많이 바뀌는 사이클은 전력이 더 듦.

**핵심 등식**:

> 갱신 시 소비 전력 ≈ k × (이전 값과 새 값의 다른 비트 수) + 잡음

만약 새 값이 비밀에 의존하면, 전력도 비밀에 의존하게 됩니다. 옆에서 전력만 측정해도
비밀의 일부 정보가 흘러나오는 거예요.

### 어떻게 측정하나

CW305 보드는 친절하게도 **FPGA 코어 전원선에 0.1Ω 직렬 저항**을 박아놓고 그 위에서
차이 전압을 OPAMP로 증폭해 SMA 단자로 빼줍니다. scope이 그걸 ADC로 192 MHz로 찍어
"전압 vs 시간" 그래프 (= power trace) 로 만들어요.

```
   전압
    │            ╱╲    ╱╲
    │      ╱╲  ╱  ╲  ╱  ╲   ← register 갱신할 때마다 작은 spike
    │  ╱╲╱  ╲╱    ╲╱    ╲╲
    └───────────────────────► 시간
```

이 trace의 **어느 지점에서, 어느 정도 크기로 비밀에 의존하는가** — 그게
부채널 분석의 핵심.

---

## 3. PQC와 NTT butterfly

### Post-quantum cryptography

양자컴퓨터가 등장하면 RSA, ECC 같은 기존 암호는 깨집니다 (Shor's algorithm). NIST는
**lattice 기반 PQC** 를 표준으로 채택했어요:
- **Kyber (= ML-KEM)**: 키 캡슐화 (대칭키 공유)
- **Dilithium (= ML-DSA)**: 디지털 서명

두 알고리즘 모두 **다항식 곱셈** 을 핵심 연산으로 씁니다. 256개 계수짜리 다항식 × 다른
다항식. 이걸 빠르게 하려면 **NTT (Number Theoretic Transform)**.

### NTT란

푸리에 변환을 정수 mod q에서 한 것. 다항식 곱셈을 NTT 도메인에서는 **점곱**으로
바꿔서 O(n log n) 가능. 알고리즘 흐름:

```
다항식 a(x), b(x)
   │                        ┌─────────┐
   │ NTT 변환 (forward)     │  butterfly │
   │                        │  로 구성    │
   │                        └─────────┘
   ▼
NTT(a)  *  NTT(b)         ◀── 점곱 (단순)
   │
   │ 역NTT (inverse)
   │
   ▼
a · b 다항식 결과
```

forward와 inverse 둘 다 **butterfly의 반복** 으로 구현됩니다.

### Butterfly 한 번

butterfly는 NTT 알고리즘의 가장 작은 building block. 숫자 두 개 받아서 새 숫자 두
개 만듭니다:

```
            ζ (회전 인자, ROM에서 가져옴)
            │
            ▼
   a ──┬─────────────────────────────► out1 = (a + b·ζ) mod q
        │
        │       ↑ b를 ζ와 곱한 뒤
        │       ↑ a에 더하기 (out1) / 빼기 (out2)
        │
   b ──┴─────────────────────────────► out2 = (a − b·ζ) mod q
```

**모드 두 가지**:
- **CT (Cooley-Tukey, mode=1)**: forward NTT용. `out1 = a+b·ζ, out2 = a-b·ζ`
- **GS (Gentleman-Sande, mode=0)**: inverse NTT용. `out1 = a+b, out2 = (a-b)·ζ`

차이는 ζ가 어디서 곱해지냐. 우리 unified 디자인은 둘 다 한 회로로 처리.

**알고리즘 두 가지**:
- **Kyber**: q = 3329 (~12 비트)
- **Dilithium**: q = 8380417 (~23 비트)

`mode2` 신호로 선택. 두 알고리즘이 사용하는 ζ 테이블도 ROM 안에 같이 들어 있고
`mode2` 에 따라 어느 영역을 읽을지 결정.

### 비밀이 무엇이냐

PQC 사용 시나리오에서:
- `b`: secret key의 polynomial 한 계수, 또는 secret key에 의존하는 중간값. **공격
  대상**.
- `a`: 다른 polynomial 계수. 공개 상황에 따라 달라짐.
- `k`: zeta 테이블 인덱스. NTT 알고리즘 자체에서 결정. **공개**.
- `mode`, `mode2`: 알고리즘 흐름. **공개**.

→ 우리 실험은 `b` 가 비밀일 때 누설되는지 검증.

---

## 4. FPGA 파이프라인이 어떻게 굴러가는가

### 왜 파이프라인인가

butterfly 한 번을 계산하려면 곱셈, modulo, 덧셈/뺄셈 등 여러 단계 필요. 한 cycle에
다 끝내려면 회로가 너무 깊어 시계가 느려져요. 그래서 **여러 cycle 단계로 나누기**.

자동차 공장 컨베이어 비유:
```
원자재 → [도장] → [엔진] → [변속기] → [내장재] → [검사] → 완성차
        cycle1   cycle2    cycle3      cycle4     cycle5
```
각 단계마다 작업자가 1 cycle 동안 자기 일만 하고 다음 단계로 넘김. 한 차가 5 cycle
걸리지만, **매 cycle마다 1대씩 완성** (throughput 1/cycle).

butterfly도 똑같은 원리:
```
입력 → S1 → S2 → Mont1 → Mont2 → Mont3 → Mont4 → S7 → 출력
       1cyc  1cyc  1cyc   1cyc   1cyc   1cyc   1cyc
```
총 7 cycle latency. 그러나 throughput 1/cycle.

### 단계 사이의 register

각 단계 사이에 **D 플립플롭 군집 (= register)** 가 있어요. 이게 그 단계의 결과를
1 cycle 동안 잡아둬서 다음 단계가 안정적으로 받아쓸 수 있게 합니다.

```
   조합 회로 단계 1 ──▶│ register │──▶ 조합 회로 단계 2
                       │ (FF×N)  │
                       ▲────┐
                       │  clk
```

매 clock 상승 edge에서 register는 **이전 cycle 단계 1의 출력값** 으로 갱신됨. 그
순간 N개 비트가 한꺼번에 새 값으로 깜빡이고, **그게 전력 spike** 로 측정 장비에
보임.

### 이 디자인의 단계 정확히

`rtl/unified_bufferfly2.v` 의 코드를 보면:

```verilog
// Stage 1 register (S1)
reg [31:0] m1_s1, ref_zeta_s1;
always @(posedge clk) begin
    m1_s1       <= m1_in_s0;       // = b 또는 (a-b) mod q
    ref_zeta_s1 <= ref_zeta;        // ROM에서 받은 ζ
end

// Stage 2 register (S2): multiplier 결과
reg [63:0] mul_s2;
always @(posedge clk) begin
    mul_s2  <= m1_s1 * ref_zeta_s1; // 32×32 = 64bit 곱
end

// Modular_Reduction32 안에서 4 stages (Mont1~4)
reg [63:0] T_s1;  reg [31:0] m_s1;       // Mont 1단 register
reg [63:0] T_s2;  reg [63:0] mq_s2;      // Mont 2단 register
reg [31:0] t_s3;                          // Mont 3단 register
reg [31:0] r_s4;                          // Mont 4단 register (최종 reduction 결과)

// Stage 7 register (S7): 최종 add/sub
always @(posedge clk) begin
    out1 <= out1_pre;               // (a + Mont결과) mod q
    out2 <= out2_pre;               // (a - Mont결과) mod q
end
```

**총 7개 main register** + ROM 출력 + 초기 입력 register들.

---

## 5. register가 누설하는 물리적 이유

### 트랜지스터 수준에서

CMOS register 한 비트는 트랜지스터 4-6개로 구성. 비트 값이 0에서 1로 바뀔 때:
1. 트랜지스터 게이트가 열림
2. 짧은 순간 (< 1 ns) **단락 전류** 흐름
3. capacitor가 charge되며 전하 이동
4. 0→1 한 번에 약 picoamp~microamp의 전류 spike

이 spike가 0.1Ω shunt 저항 위로 흐르면서 V = IR ≈ 수십~수백 마이크로볼트 변동.

### 64-bit register의 갱신

`mul_s2` 같은 64-bit register가 한 번 갱신될 때:
- 새 값과 이전 값의 **비트 차이 수** 만큼의 트랜지스터가 toggle
- 각 toggle = 작은 전류 spike
- 64개 spike가 거의 동시에 → 합쳐져서 측정 가능한 전압 변동

### Hamming weight (HW) vs Hamming distance (HD)

- **HW (Hamming weight)**: 한 값에서 1 비트의 개수. 예: HW(0b10110100) = 4
- **HD (Hamming distance)**: 두 값 사이 다른 비트의 수. = HW(A XOR B)

register 갱신 전력 ∝ HD(이전 값, 새 값) **가 정확한 모델**.

그런데 **이전 값이 0이거나 일정한 reset 상태** 라면 HD = HW(새 값). 이 경우 HW
모델이 곧 HD 모델.

우리 디자인에서 `mul_s2` 같은 register는 매 cycle마다 갱신되어 새 값으로 채워지지만,
butterfly 시작 시점 (busy_reg=1로 켜진 직후) 의 첫 갱신은 이전 idle 상태에서
들어옴. 그래서 **첫 cycle에 한해 HW 모델이 잘 맞음**.

이게 우리 실험에서 HW(b·ζ) 가 강한 상관을 보인 이유.

---

## 6. 이 디자인의 누설점 — 단계별 그림

이제 본 핵심. cycle 단위로 무엇이 register에 들어가고, 어디서 측정에 누설이
나타나는지 매핑해요.

### Trigger 시점

wrapper 코드 (`rtl/cw305_unified_butterfly2_top_v4_directwrite.v` 라인 263):
```verilog
assign tio_trigger = busy_reg;
```

→ busy_reg가 0에서 1로 가는 그 cycle (= "C1" 이라 부르자) 에 정확히 trigger 상승.
scope이 그 순간부터 ADC sampling 시작.

ADC = 192 MHz, FPGA clock = 96 MHz → **1 FPGA cycle = 2 ADC samples**.

### 시간축 매핑

```
trigger ↑ here
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│ cycle ADC sample  무슨 일                       register 변화    │
├─────────────────────────────────────────────────────────────────┤
│  C1    0~1       busy_reg=1, a_core/b_core/    a_core, b_core    │
│                  k_core 갱신, ROM 주소 결정       (입력 latch)    │
│                                                                  │
│  C2    2~3       a_r/b_r/q_r/mode_r 갱신,       a_r, b_r, q_r,    │
│                  ROM 출력 ref_zeta 유효          ref_zeta 출력    │
│                                                                  │
│  C3    4~5       S1 register: mux + (a-b)mod q  m1_s1, ref_zeta_s1│
│                                                                  │
│  C4    6~7       ★ S2 register: mul_s2 ←       mul_s2 (64bit)    │
│                  m1_s1 × ref_zeta_s1            ─ b·ζ 등장        │
│                  (32×32 → 64-bit 곱)                              │
│                                                                  │
│  C5    8~9       ★ Mont 1단: m = (T·QPRIME)    m_s1, T_s1, q_s1  │
│                  mod 2^32                       (32+64+32 bit)   │
│                                                                  │
│  C6   10~11      ★ Mont 2단: mq = m · q         mq_s2 (64bit),    │
│                  (64-bit 곱)                    T_s2 (paas-thru) │
│                                                                  │
│  C7   12~13      ★ Mont 3단: t_s3 = (T+mq)>>32  t_s3 (32bit)     │
│                                                                  │
│  C8   14~15      ★ Mont 4단: r_s4 = t-q (보정)  r_s4 (32bit) =    │
│                                                  Montgomery 결과  │
│                                                                  │
│  C9   16~17      ★ S7 register: 최종 결과       out1, out2 (32bit │
│                  out1 = (a + r_s4) mod q       각각)              │
│                  out2 = (a - r_s4) mod q                         │
│                                                                  │
│  C10+ 18~30      busy_reg 유지, wait_count++,  (안정화 + 잔여     │
│                  결과가 register들에 안정화      transition)      │
│                                                                  │
│  C20+ 39~54      결과가 read_data 멀티플렉서를  read_data         │
│                  통해 후속 register들로 전파     muxer 변동       │
│                                                                  │
│  C73   ~146      wait_count == 72, busy_reg=0   busy_reg toggle  │
│                  done_reg=1, tio_trigger ↓                       │
└─────────────────────────────────────────────────────────────────┘
```

★ 표시된 register들이 모두 **b 의존 비트 패턴** 을 들고 있어요.

### TVLA 결과와 매핑

`b` 를 50% 고정-50% 랜덤으로 섞어 N=20000 trace 측정. 각 sample 위치에서 두 그룹 평균
전력 차이를 t-statistic 으로 표시:

```
t-stat
  +91 ┤                ┃                                                       
  +80 ┤            ┃ ┃ ┃ ┃                                                     
  +70 ┤        ┃ ┃ ┃ ┃ ┃ ┃ ┃                                                   
  +60 ┤      ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃                                                 
  +50 ┤    ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃                                                 
  +40 ┤  ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃ ┃                                               
  ━━━━┄━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ +4.5 임계
       │                                                                      
   0 ━━┃━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 0          
       │                                                                      
  ━━━━┄━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ -4.5 임계
                                  ┃ ┃ ┃                                       
  -40 ┤                          ┃ ┃ ┃ ┃ ┃                                     
  -50 ┤                        ┃ ┃ ┃ ┃ ┃ ┃                                     
  -60 ┤                      ┃ ┃ ┃ ┃ ┃ ┃ ┃                                     
  -66 ┤                      ┃ ┃ ┃ ┃ ┃ ┃ ┃                                     
       └─┬───────┬───────┬───────┬───────┬─────────────────────────────────────►
        0      15      30      45      60                            sample
              ───┬───              ───┬───
             cluster1            cluster2
             (양수, peak +91)    (음수, peak -66)
```

### 각 cluster를 의미로 해석

**Cluster 1 — sample 16~30, peak 양수 +91**:

```
sample 범위    cycle 매핑    누설 출처
────────      ──────────    ────────────────────────────────
16~17          C9           S7 register: out1, out2 갱신
18~19          C10          (직후) 안정화 + 잔여 toggle
20~21          C11          후속 register들이 새 값 받아 갱신
22~23          C12          ...
24~25          C13          ★ peak 위치 ★
                            여러 register가 b 의존 값들을 유지·전달
                            → 합산된 전력 변동 최대
26~30          C14~15       점차 감쇠
```

**왜 peak이 sample 24인가?**: 단일 register 하나가 갱신된 직후만 신호가 나오는 게 아니라, 여러 register가 동시에 b 의존 값을 들고 있는 시점이 가장 큰 누설을 만들어요. 16-30 구간 전체에 걸쳐 **여러 register의 누설이 누적·중첩** 되고, 24가 그 누적이 가장 강한 지점.

**Cluster 2 — sample 39~54, peak 음수 -66**:

butterfly 본 연산이 끝난 후, 결과 (out1, out2)가 wrapper의 `read_data` 멀티플렉서를 통해 호스트가 읽어갈 register들로 fanout되는 구간. wrapper 끝부분 코드:

```verilog
assign read_data =
    (reg_address[7:0] == 8'h00) ? a_shadow[...] :
    (reg_address[7:0] == 8'h05) ? out1_reg[...] :   // ★ b에 의존
    (reg_address[7:0] == 8'h06) ? out2_reg[...] :   // ★ b에 의존
    ...                                              // 기타: 고정값
```

거대한 mux의 입력 일부는 b 의존 (out1/out2), 나머지는 b 무관. 출력 line은 매 cycle 다른 입력을 선택하면서 toggle. 고정-b 그룹은 안정 패턴 → 평균 전력 LOW. 랜덤-b 그룹은 매번 다른 패턴 → 평균 전력 HIGH. 그래서 t = mean_fixed − mean_random < 0.

**한 줄 정리**: cluster 1 = 계산 register들의 누설, cluster 2 = 결과 fanout 단계의 누설.

### 가장 강한 누설점 식별

여러 register가 모두 누설하지만, **가장 큰 정보량**을 가진 register는 두 개:

| Register | Cycle | Sample | 들어가는 값 | 비트 폭 | b 정보 노출량 |
|---|---|---|---|---|---|
| `mul_s2` | C4 | 6~7 | b · ζ | **64 bit** | b의 모든 비트 한 번에 |
| `out1, out2` | C9 | 16~17 | (a±t_after_mr) mod q | 32 bit + 32 bit | b 의존성 유지하지만 mod q로 압축됨 |

**`mul_s2` 가 정보론적으로 가장 risky**: 64 비트가 b·ζ 그대로 들어가요. 하지만
TVLA peak은 sample 16-30이지 sample 6-7 (= C4) 가 아닙니다. 왜?

→ 누설은 **C4부터 시작해서 후속 stage들에서 점점 누적**. C4 단독으로는 약하지만, C5
~ C9까지 모두가 b·ζ 파생값을 register에 새기면서 매 cycle 누설을 추가. 실제 peak은
이 누적이 가장 큰 지점인 sample 24 부근.

비유: 음악에서 한 악기 소리는 작아도 여러 악기가 화음을 이루면 큰 소리가 되는 것 처럼.

---

## 7. 세 가지 증거

### 증거 1: TVLA peak 위치가 파이프라인 매핑과 일치

위에서 본 그대로. peak이 정확히 데이터 흐름이 모이는 cycle 8~15 (= sample 16~30)
영역에 있음. 다른 영역 (예: sample 0~5 = cycle 1~3 = 입력 latch / ROM lookup) 은
누설 약함 (b가 아직 register에 안 들어갔거나 정보량이 적음).

### 증거 2: bit-specific TVLA (Exp D)

`b` 의 12개 비트 각각에 대해 따로 TVLA를 돌려 보면:

```
bit 0:  peak |t| = 70.4 @ sample 21
bit 1:  peak |t| = 69.1 @ sample 24
bit 2:  peak |t| = 69.8 @ sample 24
...
bit 9:  peak |t| = 75.5 @ sample 24  ← 살짝 가장 높음
bit 10: peak |t| = 65.9 @ sample 24
bit 11: peak |t| = 65.3 @ sample 24
```

**모든 비트가 같은 sample 영역에서 누설** + **누설 강도가 거의 비슷**. 이건 두 가지를 의미:

1. **단일 leakage point**: 모든 비트가 한 register update 안에 노출. mul_s2 또는 그 직후 register 후보.
2. **Hamming weight 모델 검증**: 비트 위치가 개별적으로 누설하는 게 아니라 모든 비트가 합쳐진 HW로 누설. 만약 specific-bit 누설이라면 일부 비트가 매우 강하고 나머지는 약했을 것.

### 증거 3: CPA 모델 비교 (Exp E)

여러 후보 leakage 모델로 실제 측정 trace와의 상관계수를 계산:

| 모델 (true secret b=1291 가정) | best sample | \|r\| max |
|---|---|---|
| HW(b · ζ) low 32 bit | **18** | 0.063 |
| HW(b · ζ) full 64 bit | 18 | 0.063 |
| HW(t_after_mr) Montgomery 결과 | **51** | 0.037 |
| HW(out1) | 42 | 0.020 |
| HW(out2) | 18 | 0.028 |
| HW(out1 XOR a) | 16 | 0.021 |

해석:
- **HW(b·ζ) 가 sample 18에서 가장 강함** → cluster 1의 정체는 **multiplier 출력 (mul_s2) + 그 직후 Mont 1단 register들의 b·ζ 정보 누설**
- **HW(t_after_mr) 가 sample 51에서** → cluster 2의 정체는 **Montgomery 최종 결과 (r_s4) 가 read_mux로 fanout되는 단계의 누설**

→ 두 cluster의 **물리적 정체가 다름**. cluster 1은 곱셈 직후 register들, cluster 2는 modular reduction 결과 register들.

---

## 8. 숫자로 직접 보기

### 시나리오: Kyber CT, k=16, ζ = 296

```
butterfly 식: out1 = (a + b·ζ) mod q
             out2 = (a − b·ζ) mod q
             a, ζ는 매 trace 같음, b만 변동.

a = 0xCAFEBABE = 3405691582, q = 3329, ζ = 296
```

세 개의 b 값을 잡아서, mul_s2 register에 들어가는 값과 그 HW (Hamming weight) 를
비교:

```
case A: b = 1
  mul_s2 = 1 · 296 = 296
       = 0x0000000000000128
       = 0000_..._0000  0001_0010_1000  (64 bit)
  HW = 4 (1이 4개)

case B: b = 1000
  mul_s2 = 1000 · 296 = 296000
       = 0x0000000000048480
       = 0000_..._0000  0000_0100_1000_0100_1000_0000  
  HW = 6

case C: b = 3328 (Kyber 최댓값)
  mul_s2 = 3328 · 296 = 985088
       = 0x00000000000F0680
       = 0000_..._0000  1111_0000_0110_1000_0000  
  HW = 7

case D: b = 1291 (Exp E 의 비밀)
  mul_s2 = 1291 · 296 = 382136
       = 0x000000000005D4F8
       = 0000_..._0000  0101_1101_0100_1111_1000  
  HW = 11
```

→ **HW가 4, 6, 7, 11 로 b마다 다름**. 이 차이가 **mul_s2 register 갱신 시 toggle하는
   비트 수의 차이**, 곧 전력 차이.

### 한 trace의 전력 모양 (개념)

```
전압 (uV)  
  +50 ┤                               ╱╲
   +0 ┤━━━━━━╱╲━━━━━━━━━━━━━━━━━━╱╲╱  ╲╱╲━━━━━━━━━━━━━━━━━━━
  -50 ┤   ╱╲╱  ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱  ╲╱      ╲╱╲╱╲╱╲╱
       └─┬───┬───┬───┬───┬───┬───┬───┬───────┬─────►
        ADC 0    4    8   12   16   20   24                sample
                                       ▲
                                  여기 peak 보임
                                  (cycle 12~13 = Mont 후반)
```

trace 한 개에서는 신호가 잡음에 묻혀 잘 안 보여요 (잡음 ~수십 uV). 그런데 **수만 개
trace 평균** + **두 그룹 비교 (TVLA)** 하면:
- 잡음은 √N 으로 줄어듦
- 신호는 그대로 → SNR 향상
- 결과적으로 |t| = 91 같은 압도적 통계량

### 잡음 vs 신호 

비유: 콘서트홀에서 한 사람이 속삭이는 걸 들으려는데 박수 소리가 시끄러워요. 한 번
들으면 안 들리지만, 같은 속삭임을 1000번 평균내면 박수는 평균 0이 되고 속삭임만
남아 들리게 돼요. TVLA는 정확히 이 통계 평균의 부채널 버전.

---

## 9. 의미와 대응책

### 보안 함의

**나쁜 소식**:
- 우리 unified butterfly2는 **현재 상태로 부채널에 매우 취약**
- |t| = 91 은 NIST PQC SCA 평가에서 즉시 fail
- CPA로 search space 14배 축소 가능 → 더 정교한 공격 (template) 으로는 완전 복구 가능성 큼
- Kyber 사용 시나리오에서도 같은 회로를 Dilithium 모드로 돌릴 수 있어, **공격자가
  더 누설 잘 나오는 모드 (Dilithium)** 를 선택할 수 있음 (downgrade 공격)

**좋은 소식 (방어 측면)**:
- 누설점이 명확히 식별됨 → 정확히 거기만 보호하면 됨
- HW 누설로 확정 → boolean masking 같은 표준 대응책 적용 가능
- mode 자체는 leak-clean → 단일 마스킹 스킴이 CT/GS 양쪽 적용 가능

### 대응책 옵션

가장 단순한 것부터:

**1. Boolean masking (= secret splitting)**

원래: register에 secret-dependent value `v` 가 들어감 → HW(v) 누설
방법: random share `r` 을 추가해서 register A에 `v ⊕ r`, register B에 `r` 을 따로 저장
결과: 어느 한 register만 봐도 random 처럼 보임 → HW 누설이 secret과 독립됨

이걸 multiplier 출력 register와 후속 stage들에 적용. 회로 면적 약 2배, 속도 약간
저하.

**2. Shuffling (실행 순서 무작위화)**

원래: butterfly가 매번 같은 순서로 같은 cycle에 진행 → trace 정렬 깨끗
방법: 알고리즘 레벨에서 polynomial 계수 처리 순서를 랜덤화
결과: trace 정렬이 깨져서 평균이 의미가 사라짐. CPA 어려워짐.

회로 변경 거의 없음 (소프트웨어 레벨), 효과 제한적 (template attack 가능).

**3. Hiding (전력 패턴 균일화)**

dummy 회로 추가, dual-rail 회로, Asynchronous 등. 면적/전력 큰 페널티. 학술적.

### 실용적 권장

이 프로젝트가 시장에 나갈 게 아니라 **연구 목적의 SCA 평가 플랫폼**이라면:
- 현재 상태로 누설 측정·분석 도구 (TVLA, CPA, template) 검증에 사용 가능
- 나중에 boolean-masked 버전을 만들어 같은 측정 인프라로 비교하면 **대응책의 효과를
  정량 측정** 가능 — 이게 실은 가장 가치 있는 후속 연구

---

## 부록 A: 관련 RTL 파일 매핑

| 누설 지점 | 파일 | 라인 | 설명 |
|---|---|---|---|
| 입력 latch | `cw305_unified_butterfly2_top_v4_directwrite.v` | 150~221 | a_core, b_core, k_core 등 |
| ROM 조회 | `unified_butterfly2_top.v` | 36~41 | blk_mem_gen_0 instance |
| S1 register | `unified_bufferfly2.v` | 39~50 | m1_s1, ref_zeta_s1 |
| **S2 register (mul_s2)** | `unified_bufferfly2.v` | 53~62 | **64-bit 곱셈 결과 — 핵심 누설** |
| Mont 4 stages | `Modular_Reduction32.v` | 25~74 | Montgomery 감산기 4단 |
| **S7 register (out1, out2)** | `unified_bufferfly2.v` | 117~120 | **최종 결과 — 핵심 누설** |
| read_data 멀티플렉서 | `cw305_unified_butterfly2_top_v4_directwrite.v` | 226~253 | cluster 2 누설 원인 |

## 부록 B: 더 알고 싶을 때

- TVLA 표준: ISO/IEC 17825, NIST IR 8413
- Kyber/Dilithium 사양: NIST FIPS 203 (ML-KEM), FIPS 204 (ML-DSA)
- CPA 입문: Mangard et al. *Power Analysis Attacks: Revealing the Secrets of Smart Cards* (2007)
- ChipWhisperer 튜토리얼: https://chipwhisperer.readthedocs.io/

질문 있으면 docs/experiments/ 의 각 실험 문서로.
