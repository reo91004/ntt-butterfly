# 이 프로젝트가 뭘 하는지, 어디서 비밀이 새는지 — 처음부터

이 문서는 **이 저장소를 처음 보는 사람**이 다음 네 가지를 한 번에 잡을 수 있도록
쓴 것이다.

1. 우리가 결국 **뭘 만들고**, **왜 만들었나**.
2. 저장소 안의 **코드와 회로가 각각 무엇을 담당하나**.
3. 실험 결과가 **왜 서로 정합한가**, 그리고 **무엇은 아직 모르는가**.
4. 처음 읽을 때 **놓치기 쉬운 포인트**.

Verilog / Vivado / FPGA 부채널 분석을 처음 들어보는 독자를 가정한다. 비유는
필요한 곳에만 한두 번 쓰고, 나머지는 회로와 숫자 자체로 설명한다.

---

## 목차

1. [큰 그림 한 페이지](#1-큰-그림-한-페이지)
2. [사전 지식](#2-사전-지식)
3. [측정 환경 — 보드와 장비](#3-측정-환경--보드와-장비)
4. [회로 (RTL) — 무엇이 무엇을 하는가](#4-회로-rtl--무엇이-무엇을-하는가)
5. [호스트 코드 — 무엇이 무엇을 하는가](#5-호스트-코드--무엇이-무엇을-하는가)
6. [한 trace를 캡처할 때 일어나는 일](#6-한-trace를-캡처할-때-일어나는-일)
7. [누설점 — 어느 register, 어느 sample](#7-누설점--어느-register-어느-sample)
8. [실험 6개의 논리 흐름](#8-실험-6개의-논리-흐름)
9. [결과가 정합한 이유](#9-결과가-정합한-이유)
10. [정직한 후퇴 — 무엇을 회수했고 왜](#10-정직한-후퇴--무엇을-회수했고-왜)
11. [자주 놓치는 점들](#11-자주-놓치는-점들)
12. [다음 단계](#12-다음-단계)

---

## 1. 큰 그림 한 페이지

### 한 줄 답

> **"양자내성암호 (PQC) 의 핵심 연산을 한 회로에 통합해 만들었더니, 그 회로가
> 입력에 의존하는 전력 정보를 새는지 측정하는 평가 플랫폼."**

### 풀어 쓰면

- **만든 것**: Kyber와 Dilithium 두 PQC 알고리즘이 공통으로 쓰는 *butterfly*
  연산을 단일 FPGA 회로 (`unified_butterfly2_core`) 로 통합한 디자인.
  CT (forward NTT) 와 GS (inverse NTT) 두 모드를 `mode` 신호로 선택,
  Kyber/Dilithium 두 modulus 도 `mode2` 로 선택. ζ 테이블은 ROM에 통합 저장.
- **왜 통합했나**: 칩 면적 절약. 두 알고리즘을 별도 회로로 두면 면적이 두 배.
  그런데 그렇게 절약한 회로가 **부채널 측면에서도 안전한가?** 이게 핵심 연구
  질문.
- **측정한 것**: FPGA 코어 전원선의 전압을 ADC로 192 MHz로 sampling하면서,
  같은 입력에 대해 매번 비밀에 의존하는 power 변동이 얼마나 보이는지 통계로
  검출.
- **현재까지의 답**:
  - **누설은 확실히 있다**. canonical 입력 (`a, b < q`) 조건에서도 TVLA
    peak |t| 가 88-98로, NIST PQC 평가 표준 임계값 4.5를 압도. butterfly
    파이프라인의 첫 몇 cycle 안에서 즉시 검출.
  - **위치 해석은 두 단계로 수정됨**. A-E만 보면 peak가 S7/post-result window와
    겹쳐 core output 누설처럼 보인다. Exp F는 normal capture의 강한 peak에
    `REG_B` write/input path 상태가 크게 섞인다는 것을 보였다. Exp G는 그 path를
    fixed로 scrub해도 내부 preload로 `b_core`가 바뀌면 다시 `|t|=29.8-33.7` peak가
    남는다는 것을 보였다. 즉 write path artifact만이 아니라 core/Montgomery/S7 이후
    값 의존 누설도 실제로 존재한다.
  - **CT/GS 모두 같은 위치에서 누설**. mode mux가 별도의 신규 cluster를 만들지는
    않음. 다만 단일 알고리즘 분리 구현과 직접 비교한 baseline은 아직 없음.
  - **Dilithium 이 더 강하게 누설**. operand bit 폭이 12-bit 에서 23-bit 로
    커지면서 register 갱신 시 toggle 비트 수가 늘어남.
  - **단순 HW (Hamming-weight) CPA로 secret 복구는 canonical 조건에서 실패**.
    TVLA 가 검출에 성공한 것과 별개로, naive 한 single-sample 공격은 후보
    공간을 줄이지 못함. 더 정교한 공격은 미평가.

### 이 문서를 읽고 나면 알 수 있는 것

- 회로/입력 경로의 어느 cycle, 어느 sample 위치가 누설 후보인지.
- 그게 왜 그 위치인지 (RTL 라인 단위).
- 6개 실험 (A~F) 이 각각 어떤 질문을 답하는지, 결과가 어떻게 서로를 보강하는지.
- "TVLA fail" 과 "공격 성공" 이 다른 이야기인 이유.

---

## 2. 사전 지식

### 2.1 Verilog · Vivado · FPGA

이 세 가지는 디지털 회로 작업에서 **언어 → 툴 → 하드웨어** 의 흐름.

- **FPGA (Field-Programmable Gate Array)**: 공장에서 굳어진 칩이 아니라 *내부
  배선을 사용자가 다시 정의할 수 있는* 칩. 같은 칩에 어제는 카메라 처리 회로,
  오늘은 암호 연산 회로를 올릴 수 있음. 우리는 Xilinx Artix-7 칩이 올라간
  CW305 보드를 씀.
- **Verilog**: 회로를 글로 적는 언어. C 비슷한 문법이지만 *동시에 모든 always
  블록이 한꺼번에 동작* 하는 hardware 의미가 다름. `rtl/*.v` 파일들이 전부
  Verilog.
- **Vivado**: Verilog → bitstream 으로 변환해주는 Xilinx의 합성/배치 툴.
  결과물은 `.bit` 파일. CW305 의 USB 인터페이스를 통해 FPGA에 올림.
- **합성 (synthesis)**: Verilog → 게이트 네트리스트로 번역.
- **배치배선 (place & route)**: 게이트들을 실제 칩 안의 LUT/FF/DSP 위치에
  배치하고 배선 결정.

이 저장소는 합성 결과물 (`bitstream/cw305_unified_butterfly2_top_v4.bit`) 을
올린 뒤 외부에서 power만 측정. 합성 과정을 직접 파보지 않아도 본 글의 누설 분석
은 따라갈 수 있음.

### 2.2 Register 와 클럭 — Verilog 회로의 두 단어

- **register (= flip-flop, FF)**: 1 bit 짜리 메모리 한 칸. 클럭 상승 edge에서
  입력 값을 잡아 출력으로 내보냄. 32-bit register는 FF 32개 묶음.
- **클럭**: 회로 전체가 같은 박자로 움직이게 하는 신호. 우리 디자인은 96 MHz.
  즉 1 cycle = 약 10.4 ns.
- **조합 회로 (combinational)**: register 사이의 게이트 묶음. 같은 cycle 안에서
  계산 끝남.
- **파이프라인 (pipeline)**: 긴 조합 회로를 여러 register로 잘라 매 cycle 한
  단계씩 진행하게 만드는 구조. 한 결과를 내는 데 *latency* 가 늘어나지만 매
  cycle 새 입력을 받을 수 있어 throughput 은 1/cycle.

전력 누설의 핵심: **register 갱신 = FF 안의 비트가 새 값으로 토글 → 트랜지스터
가 전류를 끌어다 씀 → 측정 장비에서 전압 spike**.

### 2.3 Kyber · Dilithium · NTT · butterfly

NIST가 양자내성암호 표준으로 채택한 두 알고리즘.

- **Kyber (= ML-KEM)**: 키 캡슐화 (대칭키 공유). modulus q = 3329, 약 12 bit.
- **Dilithium (= ML-DSA)**: 디지털 서명. modulus q = 8380417, 약 23 bit.

두 알고리즘 모두 **256개 계수짜리 다항식** 끼리 곱하는 게 핵심 연산. 단순한
계수별 곱셈은 O(n²) 라 느림. **NTT (Number Theoretic Transform)** 라는 정수판
푸리에 변환을 쓰면 다항식 곱셈이 NTT 도메인에서는 *점곱* 으로 바뀌고 전체가
O(n log n).

NTT 의 가장 작은 building block 이 **butterfly**: 정수 두 개 (`a`, `b`) 와
회전 인자 (`ζ`, ROM에서 lookup) 를 받아 정수 두 개를 만듦.

```
CT (Cooley-Tukey, mode=1, forward NTT용):
    out1 = (a + b·ζ) mod q
    out2 = (a − b·ζ) mod q

GS (Gentleman-Sande, mode=0, inverse NTT용):
    out1 = (a + b)         mod q
    out2 = ((a − b) · ζ)   mod q
```

차이는 ζ 가 어디서 곱해지냐. 우리 unified 디자인은 *둘 다* 한 회로로 처리하고
`mode` 신호로 선택. `mode2` 신호로는 modulus (Kyber 3329 vs Dilithium 8380417)
를 선택.

### 2.4 Montgomery reduction — 왜 직접 mod q 를 안 쓰는가

`mod q` 는 나눗셈인데 회로에서 나눗셈은 비싸다 (수십 cycle, 큰 면적). 대신
**Montgomery reduction** 이라는 트릭을 씀.

- 모든 값을 `R = 2^32` 만큼 곱한 *Montgomery 도메인* 에서 다룸.
- `mod q` 대신 `mod 2^32` (= 그냥 하위 32 bit 자르기) 와 한 번의 보정만 필요.
- 우리 회로에서 4 cycle 파이프라인 ([Modular_Reduction32.v:25-74](../rtl/Modular_Reduction32.v))
  으로 구현되어 있고, 결과는 `r = a * R⁻¹ mod q`.

상세 식은 회로 주석에 있고, 부채널 분석에서는 **"4 cycle 동안 64-bit register
들이 b 의존 값으로 갱신된다"** 만 기억하면 된다.

### 2.5 부채널이 무엇인가 — 회로 단위로

CMOS register 한 비트는 트랜지스터 4-6개로 만들어짐. 비트가 뒤집힐 때:

1. 게이트가 열리고 닫히면서 짧은 단락 전류 (수십 picosec).
2. 출력 노드의 capacitor 에 전하가 채워지거나 빠짐.
3. 한 비트 toggle 당 수 picoamp 수준의 전류 spike.

64-bit register 가 한 cycle 에 동시에 갱신되면 toggle 한 비트 수만큼의 전류
spike 가 합쳐져서 측정 가능한 전압 변동을 만듦.

핵심 공식 (단순화):

> **갱신 시 동적 소비전력 ∝ HD(이전 값, 새 값) + 잡음**

여기서 HD = Hamming distance = `popcount(이전 ⊕ 새)`. 이전 값이 0이거나 일정한
reset 상태면 HD = HW(새 값) = popcount(새 값). 우리는 `mul_s2` 같은 register
가 매 cycle 갱신되며 새 b 값에 의존하는 패턴을 들고 있는지를 측정함.

CW305 보드는 **FPGA 코어 전원선에 0.1Ω shunt 저항** 을 박아놓고 그 위 차이
전압을 OPAMP로 증폭해 SMA 단자로 빼줌. scope이 그걸 192 MHz 로 ADC 변환해
시간축 vs 전압 그래프 (= power trace) 를 만듦.

---

## 3. 측정 환경 — 보드와 장비

### 3.1 하드웨어

- **CW305**: Xilinx Artix-7 FPGA 가 올라간 부채널 평가용 보드. 핵심 특징:
  - `usb_clk` 96 MHz 클럭을 SAM3U 마이크로컨트롤러가 공급.
  - 코어 전원선에 shunt 저항 + OPAMP → SMA 출력.
  - 호스트 PC와 USB 로 register read/write.
- **ChipWhisperer-Husky-Plus**: scope. ADC 250 MHz까지 지원. 외부 클럭 입력에
  PLL 을 lock해서 sample point 가 target FPGA 의 cycle 에 정확히 정렬되게 함.
- **연결 (3 라인)**:
  - SMA (ADC 입력): CW305 의 코어 전원 측정 출력.
  - tio_clkin / tio_clkout: scope 의 PLL 입력 ← FPGA 의 96 MHz 클럭.
  - tio_trigger / tio4: scope 의 trigger 입력 ← FPGA 의 trigger_reg 신호.

### 3.2 클럭과 ADC 비율

- target clock = 96 MHz (FPGA `usb_clk`).
- ADC clock = `target_freq × adc_mul = 96 × 2 = 192` MHz.
- 즉 **1 FPGA cycle = 2 ADC sample**.
- 스코프 trace 의 sample 16 → cycle 8 → … 같은 매핑이 가능.

`adc_mul=4` (384 MHz) 는 Husky 의 LMK PLL 스펙 한계 밖이라 silently clamp 됨.
그래서 default 가 `adc_mul=2`. ([host/sca_config.py:35-46](../host/sca_config.py))

### 3.3 trigger 정렬이 왜 중요한가

trigger 가 들쭉날쭉하면 매 trace 의 sample 0 이 다른 cycle 에 떨어져서 평균을
내도 신호가 흐려짐. 두 옵션:

- **internal (default)**: wrapper 가 `tio_trigger = trigger_reg` 로 구동.
  ([rtl/cw305_unified_butterfly2_top_v4_directwrite.v](../rtl/cw305_unified_butterfly2_top_v4_directwrite.v))
  default trigger delay 0에서는 butterfly 시작과 *같은 cycle* 에 trigger 가
  올라감 → sub-cycle 정렬. 이걸 쓰려면 wrapper 를 다시 합성해야 함.
- **host-toggle (legacy)**: 옛 wrapper 처럼 USB로 호스트가 `usb_trigger_toggle()`
  로 흔듦. USB 트랜잭션 지연 (~125 us) 이 trigger 시점에 들어가 sample window 가
  훨씬 넓어야 함.

이 저장소는 internal 만 씀. 새로 캡처할 때 sample 0 ~ 17 사이에 input register,
ROM, S1, S2 가 갱신되는 모습이 깨끗하게 보이는 이유가 이거다.

---

## 4. 회로 (RTL) — 무엇이 무엇을 하는가

`rtl/` 안에는 6개 Verilog 파일이 있고, 핵심은 4개.

```
cw305_unified_butterfly2_top_v4_directwrite.v   ← USB wrapper
   └── unified_butterfly2_top.v                  ← ROM lookup + 1-cycle 입력 reg
          └── unified_bufferfly2.v               ← butterfly core (S1~S7)
                 └── Modular_Reduction32.v       ← Montgomery (4-stage)
```

나머지 두 개 (`mux2_1.v`, `demux1_2.v`) 는 옛 버전의 sub-module 로, 현재 core
는 그 로직을 inline 했지만 다른 곳에서 instantiate 될 수 있어 남아 있음.

### 4.1 `Modular_Reduction32` — Montgomery 4 stage

입력 64-bit `a`, modulus `q` → 4 cycle 후 `r = a * R⁻¹ mod q`.

```
S1: m_s1 = (a[31:0] * QPRIME) mod 2^32      ← 32×32 곱
S2: mq_s2 = m_s1 * q                         ← 32×32 곱 → 64-bit
S3: t_s3  = (T_s2 + mq_s2) >> 32             ← 65-bit 덧셈, 상위 32 bit
S4: r_s4  = (t_s3 >= q) ? t_s3 - q : t_s3   ← 보정
```

`QPRIME` 은 q에 따라 결정되는 상수: Kyber 면 `0x94570CFF`, Dilithium 이면
`0xFC7FDFFF`. ([rtl/Modular_Reduction32.v:33-34](../rtl/Modular_Reduction32.v))

부채널 관점: 4 cycle 동안 `T_s1/T_s2`(64 bit), `mq_s2`(64 bit), `t_s3`(32 bit),
`r_s4`(32 bit) 가 매 cycle 새 b 의존 값으로 갱신됨. 누설 양이 큼.

### 4.2 `unified_butterfly2_core` — butterfly 본체

7 cycle latency 파이프라인.
([rtl/unified_bufferfly2.v:26-122](../rtl/unified_bufferfly2.v))

```
S0 (조합): m1_in_s0 = mode ? b : (a-b) mod q   ← CT vs GS 분기
S1 (reg): m1_s1, ref_zeta_s1, a_s1, b_s1, q_s1, mode_s1
S2 (reg): mul_s2 = m1_s1 * ref_zeta_s1         ← 32×32 → 64 bit
S3-S6   : Modular_Reduction32 4 stages
S7 (reg): out1 = (a + m3) mod q
          out2 = (a - m3) mod q  (CT) 또는 t_aligned (GS)
```

CT 면 `m1 = b`, GS 면 `m1 = (a-b) mod q`. 이 분기 때문에 cpa.py 의 leakage
model 도 mode 별로 분리해야 정합. ([host/cpa.py:71-82](../host/cpa.py))

`(a >= b) ? (a-b) : (a+q-b)` 는 한 번의 보정만 하는 식이라 **`a, b < q` 일 때만**
정확히 `(a-b) mod q`. 이게 "canonical input" 의 의미.

### 4.3 `unified_butterfly2_top` — ROM lookup + 1 cycle 입력 reg

butterfly core 앞단에 ROM 과 입력 register 한 stage 를 붙임.
([rtl/unified_butterfly2_top.v:1-69](../rtl/unified_butterfly2_top.v))

ROM (`blk_mem_gen_0`, IP `ip/unified_zeta.coe`) 의 1024 entry 구성:

```
0   ~ 127  : Kyber inv_zeta
256 ~ 383  : Kyber zeta
512 ~ 767  : Dilithium inv_zeta
768 ~ 1023 : Dilithium zeta
```

`mode2 + mode` 조합으로 base 주소를 결정하고 `k` 입력으로 offset.
`mode2=0, mode=1` → base 256, k 입력으로 Kyber forward zeta lookup.

ROM read 는 1 cycle latency 라 a/b/q/mode 도 같이 1 cycle delay.

### 4.4 `cw305_unified_butterfly2_top_v4` — wrapper

USB register 인터페이스. butterfly core 자체는 USB와 무관하지만, 호스트가 입력
을 쓰고 결과를 읽으려면 register 가 필요.
([rtl/cw305_unified_butterfly2_top_v4_directwrite.v:1-269](../rtl/cw305_unified_butterfly2_top_v4_directwrite.v))

호스트 → wrapper 레지스터 맵 (sca_config.py 와 일치):

| 주소 | 이름 | 용도 |
|---|---|---|
| 0x00 | A | a 입력 (4 byte LE) |
| 0x01 | B | b 입력 (4 byte LE) |
| 0x02 | K | zeta 인덱스 (2 byte) |
| 0x03 | CTRL | bit0=mode, bit1=mode2, bit2=use preload, bit3=force b_core=0, bit4=route B write to preload, bit[7:5]=trigger delay |
| 0x04 | STATUS | write bit0=start / bit1=clear_done; read bit0=done / bit1=busy |
| 0x05 | OUT1 | 결과 1 (4 byte LE) |
| 0x06 | OUT2 | 결과 2 (4 byte LE) |
| 0x07 | B_PRELOAD | preload readback (4 byte LE) |
| 0x7E | ID | 0xC4 (sanity check) |

호스트가 입력 4개를 쓰고 0x04 에 `0x01` 을 쓰면 `busy_reg = 1` 이 되고
butterfly core 가 시작. `trigger_reg`는 `CTRL[7:5]` delay 뒤에 올라가며, default
delay 0에서는 start와 같은 cycle에 올라간다. core 자체는 7-cycle pipeline이고,
wrapper start 기준으로 `out1_wire/out2_wire` 는 약 8 cycle 뒤 valid가 된다. 현재 wrapper는
`CAPTURE_DELAY=72` 동안 trigger를 더 유지한 뒤 `busy_reg = 0` 으로 떨어뜨리며
readback용 `out1_reg / out2_reg` 에 결과를 latch한다. 즉 72 cycle은 butterfly
latency가 아니라 post-result capture/readback hold window다.

`assign tio_trigger = trigger_reg` 로 trigger 가 sub-cycle 정확.

---

## 5. 호스트 코드 — 무엇이 무엇을 하는가

`host/` 안의 파이썬 스크립트 4 + 1.

### 5.1 `capture_traces.py` — 측정 루프

1. ChipWhisperer 디바이스 자동 감지 (CW305 + Husky-Plus).
2. scope clock 설정 (`adc_mul=2` → 192 MHz).
3. (옵션) bitstream 으로 FPGA 프로그램.
4. N trace 루프:
   - 입력 a/b/k 결정.
     - `--vary b` (TVLA용): b 가 50% 고정 / 50% 랜덤 [0, q).
     - `--vary k` (CPA용): k 가 균등 [0, k_max), b 고정.
   - USB로 register 0x00~0x03 에 입력 쓰기.
   - scope 무장 (`scope.arm()`) → 0x04 에 `0x01` 쓰기 → trigger_reg 가 trigger 상승.
   - done 비트 폴링 → `out1/out2` 읽기.
   - scope 에서 ADC trace 회수.
5. `traces.npy`, `inputs.npz`, `metadata.json` 저장.

중요한 정합성 보정 두 군데:

- `a` 를 `q` 로 reduction 한 뒤 FPGA 에 주입.
  ([host/capture_traces.py:439-444, 491](../host/capture_traces.py)) RTL의 한
  번-보정 modular 산술이 `a, b < q` 를 가정하기 때문. 원본은 `a_raw` 로 보존.
- `seed = 0xC0FFEE` 가 모든 실험에서 동일 → **같은 b 시퀀스, 같은 group 할당** →
  실험 간 paired 비교 가능.

### 5.2 `tvla.py` — fixed-vs-random TVLA

- group 0 (fixed b) trace 와 group 1 (random b) trace 의 평균/분산을 sample 별로
  내고 Welch's t-statistic 계산.
- |t| > 4.5 인 sample 이 하나라도 있으면 leak 으로 판정 (NIST PQC SCA 평가
  기준). ([host/tvla.py:28-37, host/sca_config.py:33](../host/tvla.py))
- `tvla_t_stat.npy`, `tvla_plot.png` 저장.

### 5.3 `specific_tvla.py` — 비트별 TVLA

같은 데이터를 `b` 의 각 bit 위치별로 다시 그룹화해서 어떤 bit 가 가장 강하게
누설하는지 본다. **단, fixed half 가 들어가면 안 된다** — 고정 b 값이 모든 bit
split 의 한 쪽에 통째로 들어가서 원래 fixed-vs-random 차이가 다시 보임.

수정 후 default 는 `--cohort auto`: fixed/random 둘 다 있으면 random 만 선택.
([host/specific_tvla.py:36-49, 93-104](../host/specific_tvla.py)) 출력 파일명도
`spec_tvla_random_*` 로 구분.

### 5.4 `cpa.py` — Correlation Power Analysis

CPA 는 secret 후보를 *직접 추측해서* 점수를 매기는 공격.

- 모든 candidate `b_hyp ∈ [0, q)` 에 대해:
  - 각 trace 에서 **leakage 모델 prediction** 을 계산:
    - CT: `HW( (b_hyp · ζ_k) mod 2^32 )`
    - GS: `HW( ((a − b_hyp) mod q) · ζ_k mod 2^32 )`
  - prediction 과 trace[:, sample] 의 Pearson correlation 을 sample 별로 구해
    `score(b_hyp) = max_s |r|`.
- score 가 가장 높은 candidate 가 winner. `winner == secret` 이면 공격 성공.

mode 별 leakage 모델 분리 ([host/cpa.py:71-82](../host/cpa.py)) 가 RTL stage-0
mux 와 일치.

### 5.5 `sca_config.py` — 공통 상수

레지스터 주소, modulus, TVLA threshold, 클럭 default. 다른 스크립트들이 import
한다.

---

## 6. 한 trace를 캡처할 때 일어나는 일

trigger 상승부터 sample 별로 무엇이 register 에 들어가는지 매핑.

```
ADC 클럭 = 192 MHz, FPGA 클럭 = 96 MHz → 1 FPGA cycle = 2 ADC sample.
trigger ↑ at sample 0 (= trigger_reg 상승 cycle).
```

| Cycle | ADC sample | 무슨 일이 벌어지나 | 새로 갱신되는 register |
|---|---|---|---|
| C1 | 0~1 | wrapper 가 a_core/b_core/k_core/mode_core 를 shadow 에서 복사, busy_reg=1 | a_core, b_core, k_core, mode_core, busy_reg |
| C2 | 2~3 | top-level a_r/b_r/q_r/mode_r 갱신, ROM 출력 ref_zeta 도착 | a_r, b_r, q_r, mode_r, ref_zeta |
| C3 | 4~5 | core S1: pre-mul mux, (a−b) mod q 계산 결과 latch | m1_s1, ref_zeta_s1, a_s1, b_s1, q_s1, mode_s1 |
| C4 | 6~7 | core S2: 32×32 mul 결과 latch | **mul_s2 (64 bit)** |
| C5 | 8~9 | Mont S1: m = (T·QPRIME) mod 2^32 | T_s1, q_s1, m_s1 |
| C6 | 10~11 | Mont S2: m·q (64 bit) | T_s2, q_s2, mq_s2 |
| C7 | 12~13 | Mont S3: 65-bit 덧셈, 상위 32 bit | t_s3, q_s3 |
| C8 | 14~15 | Mont S4: 보정 → t_after_mr | r_s4 |
| C9 | 16~17 | core S7: 최종 add/sub | **out1, out2 (32 bit)** |
| C10+ | 18~30 | core output 안정화 / post-result window | (잔여 transition) |
| C20+ | 39~54 | 새 산술 stage는 없음; 안정화된 core output의 routing/fanout 영향 후보 | core output fanout |
| C74 근처 | ~146 | wait_count == CAPTURE_DELAY, readback latch, busy_reg=0, done_reg=1, trigger 하강 | out1_reg, out2_reg, busy_reg, done_reg |

주의: 이 표는 sample이 어떤 core cycle과 겹치는지 보여준다. Exp F 이후에는
sample 위치만으로 누설원을 확정하지 않는다. normal capture에서는 `REG_B` write
직후 scope를 arm하므로, 마지막 B write/input path 상태가 core cycle window에 겹쳐
보일 수 있다. Exp G처럼 preload/scrub으로 `REG_B` start 값을 고정해야 core-only
해석이 가능하다.

---

## 7. 누설점 — 어느 register, 어느 sample

### 최신 결론: write path도 새고, core-only도 샌다

2026-05-11에 수행한 [Exp F](experiments/exp_F_input_write_isolation.md)와
[Exp G](experiments/exp_G_core_preload_isolation.md)가 이 장의 초기 해석을 갱신한다.
A-E의 TVLA fail 자체는 유효하지만, sample 위치만 보고 S7/final output register를
주 누설점으로 단정하면 안 된다.

| 실험 | 분리한 것 | peak |
|---|---|---:|
| baseline | 원래 capture loop | `|t|=33.65 @ s20` |
| S7 correction 제거 | final 조건문 제거 | `|t|=34.88 @ s21` |
| dummy output | `out1/out2`를 secret-independent로 교체 | `|t|=35.07 @ s21` |
| core `.b=0`, `b_core=0` | multiplier/MR/S7에서 secret 제거 | `|t|=33.77 @ s20` |
| 실제 FPGA B write constant | group label은 유지, `REG_B` write 값만 fixed | `|t|=3.27`, no leakage |
| random B 후 fixed B scrub | random write 뒤 arm 직전 fixed로 덮어쓰기 | `|t|=2.63`, no leakage |
| preload core-only | `REG_B` start fixed, 내부 `b_preload`/`b_core`만 fixed/random | `|t|=29.79 @ s23`, leakage |
| preload core-only, trigger delay 2 | 같은 조건, trigger만 2 cycle 뒤로 이동 | `|t|=33.66 @ s16`, leakage |
| preload traffic + force `b_core=0` | `b_preload`는 fixed/random, core 입력은 constant | `|t|=3.41`, no leakage |

따라서 normal capture protocol에서 보이는 강한 sample 20대 peak에는 **마지막
`REG_B` write/input path 상태**가 크게 섞인다. 하지만 그 path를 fixed로 scrub해도
내부 `b_core`가 바뀌면 강한 TVLA가 남는다. 최신 결론은 **host write path만이 아니라
butterfly core/Montgomery/S7 이후 값 의존 switching도 실제 누설원**이라는 것이다.

A2 캡처 (Kyber CT, k=16, N=20000) 의 TVLA 결과:

```
sample 21:  |t| = 90.32   (cluster 1 의 peak)
sample 18:  |t| = 85.34
sample 24:  |t| = 84.75
...
sample 45:  |t| = 63.56   (cluster 2 의 peak, 음수 t)
sample 51:  |t| = 62.64
임계 통과 sample: 65 / 800
```

두 cluster 는 A-E에서 반복 관측됐다. Exp F/G 이후에는 아래 설명을 "위치 기반 후보"로
읽어야 한다. normal capture에서는 write path 영향이 섞이고, preload/scrub 조건에서는
core-only 누설이 같은 window에서 재현된다.

### Cluster 1 — sample 16~30 (양수 t)

cycle C9~C15 영역과 시간상 겹친다. 초기 해석은 S7 register (out1, out2) 갱신 직후
+ 결과가 후속 register 들로 흘러가는 안정화 구간이라고 봤다. 하지만 Exp F에서
core/S7를 secret-independent하게 만들어도 같은 peak가 유지됐고, arm 직전 fixed B scrub
으로 사라졌다. 이어 Exp G에서 `REG_B` start 값을 fixed로 고정하고 내부 preload로만
`b_core`를 바꿔도 peak가 다시 나타났다. 따라서 normal capture의 peak는 write path가
지배할 수 있지만, core-only 조건에서는 `b*zeta`가 Montgomery 후반과 S7/post-result
window로 전파된 값 의존 switching으로 보는 것이 가장 정합하다.

양수 t 의 의미: "고정 b group 의 평균 전력 > 랜덤 b group 의 평균". 고정 b 값
(0x12345678 % 3329 = 791) 이 만드는 mul_s2 = 791 · ζ 의 HW 가 랜덤 b 평균
보다 크기 때문.

### Cluster 2 — sample 39~54 (음수 t)

cycle C20~C27. butterfly 본 연산은 끝났지만 post-trigger window 안에 남는 두 번째
cluster다. 예전에는 readback mux나 core output fanout 후보로 설명했지만, Exp F 이후에는
이 역시 `REG_B` write/input path의 잔여 상태 또는 그 상태가 wrapper/USB frontend에
남긴 영향까지 열어두고 해석한다. 별도 preload/scrub wrapper 없이는 core fanout이라고
확정할 수 없다.

### 비트별 누설 (Exp D)

A2 의 bit-specific TVLA (random half 9953 trace):

```
bit 10: |t| = 11.88 @ sample 18  (LEAK)
bit  9: |t| = 11.63 @ sample 18  (LEAK)
bit 11: |t| =  5.86 @ sample 18  (LEAK)
bit  7: |t| =  5.71 @ sample 15  (LEAK)
bit 0~6, 8: |t| ≤ 4.5            (임계 미달)
bit 12~31: skip (Kyber q < 2^12, 사용 안 함)
```

→ **모든 사용 bit 가 균등하게 누설하는 것이 아니다**. 9, 10, 11 (b 의 상위 비트)
+ bit 7 만 4.5 임계 통과. 단순 HW 모델은 모든 bit 에 같은 가중치를 주지만,
실측은 일부 bit 에 집중.

---

## 8. 실험 6개의 논리 흐름

`docs/experiments/` 의 A~G 가 일곱 개 질문에 차례로 답한다.

| 실험 | 답하려는 질문 | 결과 |
|---|---|---|
| **A** | 누설이 진짜 있나? 어디에 위치? | Kyber CT 베이스라인. peak \|t\|=90.3 @ sample 21. cluster 1·2 위치 확인 |
| **B** | mode (CT vs GS) 가 누설 패턴을 바꾸나? | 같은 b 시퀀스로 GS 캡처. peak·cluster 거의 동일. 단, mode mux 자체가 clean이라는 뜻은 아님 |
| **C** | 알고리즘 (Kyber vs Dilithium) 차이는? | Dilithium 으로 같은 패턴 반복. peak |t| 더 크고 누설 sample 더 많음 (operand bit 폭 ↑) |
| **D** | 어떤 bit 가 가장 강하게 누설? | bit-specific TVLA. 일부 bit 에 집중. 균등 HW 결론은 아니다 |
| **E** | 누설로 secret 복구 가능한가? | naive HW CPA. canonical 조건에서 후보 공간 축소 실패 |
| **F** | A-E의 peak가 정말 core/S7만으로 설명되나? | 아니다. normal capture peak에는 `REG_B` write/input path가 크게 섞임 |
| **G** | write path를 scrub하면 새 butterfly core는 안전한가? | 아니다. `REG_B` fixed, `b_core` fixed/random 조건에서도 `|t|=29.8-33.7` |

각 실험은 이전 실험의 데이터/결론을 *전제로* 다음 질문을 넘긴다.

- A 가 누설을 검출했기에 → B 는 "그게 mode 의존인가"를 물을 수 있음.
- B 가 mode 무관임을 보였기에 → C 는 "algorithm 차이가 진짜 누설 강도 차이를
  만드나"를 깨끗이 검증할 수 있음.
- A/B/C 데이터가 다 있기에 → D 는 비트 단위로 같은 데이터를 재해석.
- TVLA 가 *검출* 에 성공했기에 → E 는 "그럼 *공격* 도 되나"라는 별개 질문으로
  넘어감.
- A-E의 sample 위치 해석이 남아 있었기에 → F 는 "정말 core arithmetic이 원인인가"를
  isolation bitstream으로 검증함.

### A/B 가 paired 인 이유

`seed=0xC0FFEE` 가 두 캡처에서 같음. 그래서 trace i 의 b 값이 A 와 B 에서 정확
히 같음. 같은 b 가 CT 회로 vs GS 회로를 통과한 결과를 비교하는 것이라 *paired
실험* 으로서 통계적 검정력이 높음.

---

## 9. 결과가 정합한 이유

다섯 가지 정합성 근거.

### 9.1 RTL 산술 전제와 입력의 일치 (canonical input)

RTL `unified_bufferfly2.v:36` 의 `(a >= b) ? (a-b) : (a+q-b)` 는 한 번의 보정
만 하므로 **`a, b < q` 일 때만** 정확히 `(a-b) mod q`. 옛 캡처는 `a=0xCAFEBABE`
를 q 로 줄이지 않고 주입했고, 그 결과 out1/out2 가 q 이상이 되어 RTL 출력이
spec 식과 어긋남. 새 캡처는 `a` 를 q 로 reduction 후 주입.

검증: 6개 새 캡처의 inputs.npz 에서 out1/out2 모두 < q (`all<q=True`).

### 9.2 RTL stage-0 mux 와 CPA 모델의 일치

cpa.py 의 leakage model branch ([host/cpa.py:71-82](../host/cpa.py)) 가 RTL의
`m1_in_s0 = mode ? b : sub_ab_s0` 와 비트 단위로 일치. CT 면 `b`, GS 면 `(a-b)
mod q` 가 multiplier 입력. canonical 입력에서는 numpy `np.where(a>=cand, a-cand,
a+q-cand)` 가 정확히 `(a-b) mod q`.

### 9.3 fixed-vs-random TVLA 의 통계적 정합

Welch's t > 4.5 임계는 평균 차이가 노이즈 표준오차의 4.5 배 이상이면 leak 로
판정. N=20000 에서 fixed/random 분포가 다르지 않다면 |t| ≤ 4.5 가 거의 모든
sample 에서 유지되어야 함. 우리는 |t| 가 90 까지 나옴 → 거의 이론적으로 불가능
한 noise 변동. 진짜 신호.

### 9.4 같은 sample 위치에서 누설, 그리고 위치 해석의 한계

A2 peak sample = 21, B2 peak = 24, C1b peak = 24, C2b peak = 20, C-control peak
= 21. 모두 sample 18~26 안. A-E만 보면 같은 파이프라인 stage (C9 직후
post-result window)가 누설하는 것처럼 보인다.

Exp F가 이 해석을 제한한다. core/S7를 secret-independent하게 만들어도 같은 위치의
peak가 유지됐고, arm 직전 fixed B scrub으로 사라졌다. 따라서 sample 위치의 일관성은
"같은 trigger/capture protocol에서 같은 시점에 입력 write-path 상태가 관측된다"는
뜻일 수 있으며, core arithmetic localization의 충분조건이 아니다.

### 9.5 Bit 폭과 누설 강도의 비례

| 실험 | operand bit | peak \|t\| | 누설 sample 수 |
|---|---|---|---|
| Kyber CT k=16 (A2) | 12 bit | 90.3 | 65 |
| Dilithium CT k=16 (C-control) | 23 bit | 98.1 | 128 |

같은 mode/k 조건에서 bit 폭이 늘어나면 register 갱신 시 toggle 비트 수가 늘어
누설이 강해지는 게 모델과 일치.

---

## 10. 정직한 후퇴 — 무엇을 회수했고 왜

초기 분석에서 두 가지 결론을 냈다가, 검토 후 철회했다.

### 10.1 "모든 사용 bit 가 균등한 HW 누설" — 회수

- **무엇을 했나**: 초기 specific_tvla.py 가 fixed half + random half 전체를
  bit별로 재그룹화. 모든 bit 에서 |t| ≈ 65~76 이 나와 "전 bit 균등 leak"
  결론.
- **왜 잘못됐나**: fixed b (= 791) 가 모든 bit split 의 한 쪽에 똑같이 들어감.
  결과적으로 어느 bit 로 split 해도 "fixed group vs random group" 의 차이를
  다시 보는 것. 진짜 bit 의존성을 잰 게 아니라 원래 TVLA 신호가 통째로
  재출현.
- **수정 후**: random half 만 사용. 결과는 일부 bit 만 (Kyber 4/12, Dilithium
  3/23~11/23) 임계 통과. 균등 HW 결론은 폐기. ([docs/experiments/exp_D_bit_specific_tvla.md](experiments/exp_D_bit_specific_tvla.md))

### 10.2 "naive HW CPA 가 search space 를 30× 줄임" — 회수

- **무엇을 했나**: legacy 캡처 (a 가 q 로 줄지 않음) 에서 single-sample CPA 의
  true secret rank 가 120/3329 로 나옴. 후보 공간을 줄였다고 해석.
- **왜 잘못됐나**: 그 캡처의 RTL 출력 자체가 spec 식과 맞지 않는 비정규 상태.
  HW model 과 trace 사이의 상관도 그 상태 특수한 산물일 수 있음. canonical
  입력으로 다시 캡처해서 같은 분석을 하니 rank 가 1550/1829 (random guess
  수준).
- **수정 후**: legacy 결과는 "비정규 입력에서도 어떤 모델이 어느 정도
  상관된다"는 참고 기록으로만 남김. canonical 조건의 *공격 가능성* 으로
  주장하지 않음. ([docs/experiments/exp_E_cpa.md](experiments/exp_E_cpa.md))

### 두 회수의 의미

**측정과 검출은 valid**. TVLA peak 88~98, cluster 위치, bit 폭 vs 강도 비례 —
모두 그대로. 회수한 것은 **모델·공격 효율 수준의 결론** 두 가지뿐.

이건 데이터 정합성 회복이지 결과의 부정이 아니다. 오히려 "평가 플랫폼이 자기
문제를 잡아내는 능력" 의 증명에 가깝다.

---

## 11. 자주 놓치는 점들

처음 읽을 때 빠뜨리기 쉬운 사항들.

1. **TVLA 는 detector 이지 attack 이 아니다**. |t| > 4.5 가 나왔다는 건 "비밀에
   의존하는 정보가 power 에 새고 있다"의 증명일 뿐, "공격자가 그 정보로
   secret 을 실제로 복구할 수 있다"의 증명이 아님. Exp E 가 별도 질문인 이유.

2. **canonical input 의 의미**. `a, b < q` 가 아니면 RTL 의 한-번-보정 modular
   산술이 spec 과 어긋남. 옛 캡처는 `a=0xCAFEBABE` 를 그대로 주입해서
   out1/out2 가 q 이상으로 나옴. 모델 해석을 비정규 데이터에 적용하면 결론이
   왜곡됨.

3. **legacy 캡처 = 무효 데이터가 아님**. 그것은 "RTL 이 비정규 입력에서 어떻게
   누설하는가" 라는 다른 질문에 대한 측정. 단지 canonical 결론에 섞어 쓰면
   안 될 뿐.

4. **paired 캡처의 가치**. seed 가 같으면 b 시퀀스가 같음 → A vs B 비교가
   같은 입력을 두 회로 모드로 통과시킨 결과. 통계 검정력이 다름.

5. **`mul_s2`/Montgomery/S7 window는 core-only 누설 후보이자 현재 재현된 누설 window**.
   64 bit 에 b·ζ 그대로 들어가므로 정보론적으로는 위험한 register다. 그러나
   Exp F에서 core `.b`를 constant로 끊어도 normal capture의 강한 peak가 유지됐기
   때문에 sample 위치만으로는 확정할 수 없었다. Exp G의 preload/scrub 조건에서는
   external `REG_B` start 값이 fixed인데도 `b_core`가 바뀌면 sample 20대 window에서
   강한 TVLA가 재현됐다.

6. **cluster 2 (sample 39~54) 는 새 butterfly stage 가 아니다**. 현재 wrapper는
   readback register (`out1_reg/out2_reg`) 를 CAPTURE_DELAY 시점에 latch하므로,
   sample 39~54를 새 결과의 readback-mux fanout이라고 단정할 수 없다. Exp F 이후에는
   `REG_B` write/input path의 잔여 상태나 USB frontend 영향까지 열어두고 해석한다.

7. **mode mux 가 leak-clean 이라고 단정한 적 없음**. Exp B 는 "추가 cluster 가
   *관측되지 않음*" 을 보였을 뿐. 단일 알고리즘으로 분리 합성한 별도 bitstream
   과 직접 비교한 baseline 은 아직 없음. 이 baseline 을 만들려면 새 Verilog 두
   개와 두 번의 Vivado 합성이 필요해 한 세션에서 못 닫음.

8. **Kyber zeta vs inv_zeta, Dilithium zeta vs inv_zeta — 4 region**. ROM 은
   1024 entry 짜리 한 덩어리지만, base 주소가 4 군데. `mode + mode2` 조합으로
   어디를 읽을지 결정. Kyber 면 k 가 0~127 만 유효, Dilithium 이면 0~255
   유효. CPA 캡처에서 `--k-max 128` 로 잡은 이유가 이거다.

9. **Montgomery 도메인 전제**. Modular_Reduction32 의 출력은 `r = a · R⁻¹ mod
   q` 인데, 실제 NTT 흐름은 모든 operand 가 R 로 곱해진 Montgomery 도메인에
   있다고 가정. 그러면 `mul_s2 = b · ζ` 도 R 로 곱해진 상태고, 4-stage MR
   이후 R⁻¹ 이 곱해져 도메인이 보존됨. 단위 변환은 NTT 외부에서 처리하기로
   설계상 가정.

10. **Welch's t 의 4.5 임계는 문턱이지 cliff 가 아니다**. NIST PQC SCA 평가
    평가단들이 관행적으로 쓰는 "leak 으로 간주" 기준. 실제로는 1.5~2.0 도
    의심 신호. 우리는 90 이 나오므로 임계가 어디든 fail.

11. **CW305 의 usb_clk 은 96 MHz 가 *정상*, 10 MHz 는 *고장***. USB-FIFO 가
    desync 되면 클럭이 떨어져 캡처 metadata 에서 `clkgen_freq` 가 10e6 으로
    찍힘. 그러면 모든 sample 매핑이 어긋남. metadata 의 `clkgen_freq` 와
    `pll_locked` 를 항상 확인하는 이유.

12. **`a_raw` 의 존재 이유**. 새 capture_traces.py 는 a 를 q 로 줄여서 주입
    하지만, 디버그용으로 사용자가 어떤 값을 의도했는지도 metadata 에 남김.
    이게 없으면 나중에 "왜 a 가 1409 라고 적혀 있는데 코드에서는 0xCAFEBABE
    를 호출했지?" 같은 의문이 생김.

13. **분석 코드는 secret_strategy 필드를 안 읽음**. tvla.py 는 `inputs["group"]`,
    cpa.py 는 `inputs["b"][0]` 만 본다. 그래서 metadata 의 `secret_strategy`
    schema 가 변해도 분석에는 영향 없음. 다만 사람이 metadata 를 들여다볼
    때 일관된 schema 가 편하므로 모두 통일.

---

## 12. 다음 단계

- **Preload/scrub wrapper 유지**: core-only leakage는 이 구조에서 재현됐다. 이후 masking,
  shuffling, dummy butterfly 같은 countermeasure 평가는 normal capture가 아니라 이
  wrapper를 기준으로 해야 한다.
- **Separate-impl baseline**: Kyber 단독 / Dilithium 단독 bitstream 을 별도
  합성해서 같은 input/seed 로 캡처. unified vs separate 의 |t| 차이를 직접
  비교하면 "통합이 만든 신규 누설" 을 정량화 가능. (Vivado 합성 작업 필요)
- **Boolean masking 적용 후 재측정**: core-only TVLA가 재현됐으므로 다음 구현 후보.
  secret 값을 random share `r` 로 분해해 multiplier 입력 두 register 에 분산 저장하고
  |t| 가 얼마나 떨어지는지 비교.
- **Profiling/template attack**: training set 에서 leakage 모델을 추정한 뒤
  attack set 에 적용. naive HW CPA 가 실패한 canonical 조건에서도 더 정교한
  공격이 가능한지 확인.
- **Multi-sample CPA**: 단일 sample 대신 cluster 1 의 여러 sample 을 합치는
  joint CPA. 관행적으로 SNR 이 좋아짐.
- **Trace shuffling defense**: butterfly 호출 순서를 무작위화하면 cluster
  정렬이 깨져 평균 신호가 약해짐. 하드웨어 변경 거의 없이 적용 가능.

---

## 부록 A: RTL 파일과 누설 지점 매핑

| 누설 지점 | 파일 | 라인 | 설명 |
|---|---|---|---|
| **REG_B write/input path** | `cw305_unified_butterfly2_top_v4_directwrite.v` + CW305 USB frontend | 0x01 write path | Exp F 기준 normal capture peak에 크게 섞임 |
| 입력/preload latch | `cw305_unified_butterfly2_top_v4_directwrite.v` | wrapper start path | `b_core` 선택. force-zero control에서 preload 저장만으로는 TVLA 없음 |
| ROM 조회 | `unified_butterfly2_top.v` | 36~41 | blk_mem_gen_0 instance |
| S1 register | `unified_bufferfly2.v` | 39~50 | m1_s1, ref_zeta_s1 |
| S2 register (mul_s2) | `unified_bufferfly2.v` | 53~62 | `b*zeta`가 처음 명시적으로 나타나는 core-only 후보 |
| Mont 4 stages | `Modular_Reduction32.v` | 25~74 | Montgomery 감산기 4단 |
| S7 register (out1, out2) | `unified_bufferfly2.v` | 117~120 | Exp G peak window와 잘 맞는 후보 |
| post-result fanout | `cw305_unified_butterfly2_top_v4_directwrite.v` + routing | S7 이후 | Exp G에서 core-only peak가 남는 window |

## 부록 B: 호스트 코드 의존성

```
sca_config.py         ← 상수 (REG_*, KYBER_Q, DILITHIUM_Q, TVLA_THRESHOLD)
   ↑
   ├── capture_traces.py     (입력 캡처)
   ├── tvla.py               (fixed-vs-random TVLA)
   ├── specific_tvla.py      (bit-specific TVLA)
   └── cpa.py                (Correlation Power Analysis)
```

각 스크립트는 `host/results/<timestamp>_<label>/` 안에서 동작.
- capture_traces.py 는 새 폴더를 만들고 `traces.npy / inputs.npz / metadata.json`
  를 씀.
- 나머지 셋은 그 폴더를 입력으로 받아 분석 결과를 같은 폴더에 추가.

## 부록 C: 더 알고 싶을 때

- TVLA 표준: ISO/IEC 17825, NIST IR 8413
- Kyber/Dilithium 사양: NIST FIPS 203 (ML-KEM), FIPS 204 (ML-DSA)
- Montgomery reduction: Hankerson et al. *Guide to Elliptic Curve Cryptography* 2.2.4
- CPA 입문: Mangard et al. *Power Analysis Attacks: Revealing the Secrets of Smart Cards* (2007)
- ChipWhisperer 튜토리얼: https://chipwhisperer.readthedocs.io/

세부 실험 기록은 [docs/experiments/](experiments/) 의 각 문서로.
