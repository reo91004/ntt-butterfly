# 실험 C — Dilithium 비교 (CT, GS, + control)

## 목적

알고리즘을 Kyber에서 **Dilithium** 으로 바꿨을 때 누설이 어떻게 달라지는지.
unified 디자인의 가장 중요한 질문: 두 알고리즘을 같은 회로에 통합한 결과로,
한 쪽 (혹은 양쪽) 의 누설 특성이 분리 구현보다 더 나빠지는가?

## 가설

Dilithium의 q (8380417 ≈ 2²³) 는 Kyber의 q (3329 ≈ 2¹²) 보다 훨씬 큼.
- Operand 비트 폭 ↑ → multiplier 출력의 변동 폭 ↑ → register 갱신 시 bit-flip ↑
- 따라서 power 변동도 ↑ → 누설 검출 강도 ↑
- 단 **누설 위치** (어느 sample) 는 같을 것 — 같은 파이프라인 datapath이므로

## 셋업 — 3개 sub-실험

### C1: Dilithium CT, k=1
- 처음 시도, k=1을 사용 (testbench에서 검증된 값)
- 단, k=Kyber의 16과 다름 → Kyber 비교 시 k가 통제 변수가 아님 (caveat)

### C2: Dilithium GS, k=1
- C1과 같은 k에서 mode만 바꿈
- B vs A 처럼 paired 비교 가능

### C-control: Dilithium CT, **k=16** (Kyber와 동일)
- caveat 해소를 위한 control 실험
- Kyber Exp A 와 직접 비교 가능 — 이제 k가 controlled

| 파라미터 (3개 공통) | 값 |
|---|---|
| 알고리즘 | Dilithium (q=8380417), `mode2=1` |
| `a` | 0xCAFEBABE 입력, host가 q로 reduction 후 3242280을 FPGA에 주입 |
| `b` | TVLA fixed-vs-random (b_fixed=0x12345678 % q = 3724884) |
| N | 20000 traces |
| Sample window | 800 |
| seed | 0xC0FFEE |

## 명령

```bash
# C1 — Dilithium CT k=1
python3 host/capture_traces.py --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_C1_dilithium_ct_N20k \
    --mode 1 --mode2 1 --k 1 --samples 800 --no-program

# C2 — Dilithium GS k=1
python3 host/capture_traces.py --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_C2_dilithium_gs_N20k \
    --mode 0 --mode2 1 --k 1 --samples 800 --no-program

# C-control — Dilithium CT k=16 (Kyber 와 동일 k)
python3 host/capture_traces.py --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_C_control_dil_ct_k16 \
    --mode 1 --mode2 1 --k 16 --samples 800 --no-program
```

canonical rerun 데이터 위치:
- `host/results/20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k/`
- `host/results/20260510_201434_exp_C2b_dil_gs_a_mod_k1_N20k/`
- `host/results/20260510_200859_exp_C2_control_dil_ct_a_mod_k16_N20k/`

legacy 데이터 위치:
- `host/results/20260510_183408_exp_C1_dilithium_ct_N20k/`
- `host/results/20260510_183540_exp_C2_dilithium_gs_N20k/`
- `host/results/20260510_190929_exp_C_control_dil_ct_k16/`

## 결과

### 비교 표

| 실험 | 알고리즘 | mode | k | peak \|t\| @ sample | 누설 sample 수 |
|---|---|---|---|---|---|
| A2 | Kyber | CT | 16 | 90.3 @ 21 | 65 / 800 |
| B2 | Kyber | GS | 16 | 88.0 @ 24 | 82 / 800 |
| C1b | Dilithium | CT | 1 | 93.9 @ 24 | 146 / 800 |
| C2b | Dilithium | GS | 1 | 96.2 @ 20 | 116 / 800 |
| **C-control** | Dilithium | CT | **16** | **98.1 @ 21** | **128 / 800** |

### Top 5 누설 sample (C-control = 가장 엄격한 비교)

```
   1  sample 21   t=+98.126
   2  sample 24   t=+97.210
   3  sample 18   t=+95.765
   4  sample 22   t=+91.723
   5  sample 27   t=+90.257
```

## 해석

### 1. 누설 위치는 동일

C-control (k=16) 의 peak sample 21은 **Kyber Exp A2의 peak sample 21과 일치**.
즉 알고리즘과 무관하게 **같은 파이프라인 stage** 에서 누설이 발생.

C1b (k=1) 은 sample 24에서 peak — zeta 값과 mode에 따라 peak sample은 20-24 사이로
이동하지만, 모두 cluster 1 영역 안에 있음.

### 2. 누설 강도는 Dilithium > Kyber (controlled 비교에서도)

엄격한 비교 (k=16, mode=CT 통일):
- **Kyber CT k=16: peak |t| = 90.3, 65 / 800**
- **Dilithium CT k=16: peak |t| = 98.1, 128 / 800**

→ **같은 k에서도 Dilithium이 약 8.6% 높은 peak, 누설 sample은 약 2.0배**.

원인 분석:
- Kyber operand: 12-bit (b ∈ [0, 3329))
- Dilithium operand: 23-bit (b ∈ [0, 8380417))
- 32×32 multiplier 출력 `mul_s2`의 비트 변동 범위:
  - Kyber: max product < 3329² ≈ 1.1×10⁷ ≈ 24 bit → 상위 8 bit은 거의 항상 0
  - Dilithium: max product < 8380417² ≈ 7×10¹³ ≈ 47 bit → mul_s2 64 bit register
    중 47 bit 이상이 b·zeta에 의해 활성화

→ Dilithium 계산은 **2배 가까운 bit 폭**의 register 갱신 → 더 많은 bit-flip → 더
   강한 power 신호.

### 3. C2 (Dilithium GS) 의 특이점

- Peak |t| = 96.2
- 누설 sample 116 (CT k=1의 146 보다 적음)

CT (`m1 = b`)와 GS (`m1 = (a−b) mod q`) 차이가 sample 분포에 영향:
- GS는 b 값 자체가 multiplier에 들어가지 않고 `(a−b) mod q` 가 들어감
- Dilithium의 큰 q에 대한 modular subtraction은 Kyber보다 더 복잡한 비트 전이
- 결과: peak는 더 높지만 누설이 더 좁은 sample 영역에 집중

### 4. 통합 디자인 보안 영향

unified 디자인에서 **Kyber 사용자도 Dilithium 회로를 공유**. 즉 누설을 측정하는
공격자는 어느 알고리즘이 돌아가는지 알 수 있고, Dilithium 모드는 더 많은 정보를
누설. 보안 등급이 **두 알고리즘 중 약한 쪽으로 낮아짐**.

마스킹 같은 대응책은 **Dilithium 시나리오를 기준**으로 설계해야 함 (worst case).

## 파일

```
host/results/20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k/
host/results/20260510_201434_exp_C2b_dil_gs_a_mod_k1_N20k/
host/results/20260510_200859_exp_C2_control_dil_ct_a_mod_k16_N20k/
  각각 traces.npy, inputs.npz, metadata.json, tvla_t_stat.npy, tvla_plot.png
```
