# 실험 A — 대용량 TVLA 베이스라인 (Kyber, CT 모드)

## 목적

unified butterfly2 디자인의 **누설 ground truth 확립**. 표준 부채널 평가를 충분한
N으로 수행:
- 대량 trace
- 두 번째 operand `b`에 대한 fixed-vs-random TVLA
- Kyber 모듈러스 + Cooley-Tukey forward butterfly

구체적 검증 사항: 앞선 N=2000 실험에서 검출된 누설 (peak |t|=29.3) 이 N에 √N 비례로
스케일링되는지, 그리고 누설 클러스터가 capture 윈도우 어디에 위치하는지 확인.

## 가설

누설이 진짜이고 결정론적이라면, N을 10배 늘리면 (2000 → 20000) peak |t|는
√10 ≈ 3.16배가 되어야 함. 통계적 잡음이라면 그렇게 비례하지 않음.

## 셋업

| 항목 | 값 |
|---|---|
| 알고리즘 | Kyber (q=3329) |
| 모드 | CT (Cooley-Tukey, forward NTT), `mode=1`, `mode2=0` |
| Zeta 인덱스 | k=16 (zeta = ROM[256+16], Kyber 실제 사용 범위 0~127 내) |
| `a` | 0xCAFEBABE 입력, host가 q로 reduction 후 1409를 FPGA에 주입 |
| `b` | TVLA 스타일: 50% 고정 (0x12345678 % 3329 = 791), 50% 균등 랜덤 [0, 3329) |
| N | 20000 traces |
| Sample window | 800 ADC samples |
| 하드웨어 | CW305 + Husky-Plus, ADC 192 MHz |

## 명령

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_A_kyber_ct_N20k \
    --mode 1 --mode2 0 --k 16 --samples 800

python3 host/tvla.py host/results/<timestamp>_exp_A_kyber_ct_N20k/
```

canonical rerun 데이터 위치: `host/results/20260510_200546_exp_A2_kyber_ct_a_mod_N20k/`

legacy 데이터 위치: `host/results/20260510_183101_exp_A_kyber_ct_N20k/`
(`a=0xCAFEBABE`가 q로 줄지 않고 들어간 초기 실험. TVLA 누설 검출 자체는 참고 가능하지만
butterfly 출력과 GS 비교 해석에는 사용하지 않음.)

## 결과

| 지표 | 값 |
|---|---|
| 캡처 실패 | 0 / 20000 |
| 캡처 속도 | ~276 trace/s |
| Peak \|t\| | **90.321 @ sample 21** |
| \|t\| > 4.5 통과 sample 수 | 65 / 800 |
| Cluster 1 (양수 t) | sample 15–30, peak +90.3 |
| Cluster 2 (음수 t) | sample 39–54 영역에 유지 |
| 출력 범위 검증 | out1/out2 모두 `< q` |

상위 10개 누설 sample (|t| 기준):

```
순위  sample   t-stat
   1      21   +90.321
   2      18   +85.342
   3      24   +84.750
   4      22   +79.292
   5      19   +77.892
   6      27   +73.725
   7      25   +72.494
   8      45   -63.557
   9      51   -62.637
  10      30   +59.812
```

## 해석

### 1. canonical input에서 누설 재확인

초기 실험은 `a=0xCAFEBABE`를 그대로 FPGA에 주입했지만 RTL의 modular add/sub는
`a,b < q`를 전제로 한 1회 보정 구조입니다. 따라서 host capture 코드를 수정해 `a % q`
를 주입하도록 바꾸고, 동일 조건으로 다시 캡처했습니다.

새 canonical rerun에서도 peak |t|=90.321로 임계값 4.5를 압도하므로,
**입력 의존 전력 누설은 정합 조건에서도 재현됩니다**. 다만 기존 N=2000→20000 scaling
검증은 legacy 입력 조건에서의 기록으로만 남기고, canonical 조건의 scaling은 별도
반복이 필요합니다.

### 2. 누설 위치

t값 부호가 반대인 두 클러스터:

- **Cluster 1 — sample 15–30 (양수 t)**: 파이프라인 cycle C8–C15 (Mont S4 / 최종
  S7 / post-result window)에 해당. 이 cycle을 흐르는 값은 `t_after_mr` (Montgomery 후
  값) 와 최종 out1/out2 register. 양수 t = "고정-b traces가 랜덤-b traces보다 평균
  전력이 HIGH" — 고정 b 값이 multiplier 출력에서 평균보다 높은 Hamming weight를
  만들기 때문이라는 가설과 일치.

- **Cluster 2 — sample 39–54 (음수 t)**: cycle C20–C27, butterfly 후 post-result
  window. 현재 wrapper는 readback register를 CAPTURE_DELAY 시점에 latch하므로 이
  구간을 새 결과의 readback-mux fanout이라고 단정하면 안 된다. 더 보수적으로는
  core output/routing/fanout 이 안정화되는 두 번째 영역으로 해석한다. 부호가 뒤집힌 이유:
  결과값이 register/routing 부하에 분배되며 안정화되는 과정에서 고정-b 의 정상 상태가
  랜덤-b의 평균과 다르기 때문.

### 3. "secret" 이 무엇인가

TVLA 그룹화는 **`b`** (butterfly 두 번째 operand) 에 따라 했음. 누설은 *b의 함수*.
파이프라인 위치 기준 가장 가능성 높은 중간값:
- `mul_s2 = m1_s1 * ref_zeta_s1` (64-bit multiplier 출력, zeta 고정이므로 b에 선형
  의존)
- `t_after_mr` (Montgomery-reduced 출력, Kyber 범위 [0, 3328])
- `out1, out2` (최종 모듈러-q 결과)

Exp D의 corrected random-only 재분석에 따르면, fixed half를 제거하면 모든 bit가
균등하게 누설되지는 않습니다. 따라서 현재는 **operand-dependent leakage**로 표현하고,
단순 HW 모델 확정은 철회합니다.

## 파일

```
host/results/20260510_200546_exp_A2_kyber_ct_a_mod_N20k/
├── traces.npy       (20000, 800) float32  — raw ADC
├── inputs.npz       per-trace a, a_raw, b, k, mode, mode2, group, out1, out2
├── metadata.json    실험 전체 기록 (scope settings, bitfile MD5)
├── tvla_t_stat.npy  (800,) sample별 Welch's t
├── tvla_plot.png    ±4.5 임계 표시된 시각화
└── spec_tvla_random_*.npy/png  (Exp D 에서 추가)
```

## 비교 기준 역할

이 실험이 B, C, D 의 **앵커**. B는 GS 모드로 반복 (control: 같은 알고리즘, 다른
방향). C는 Dilithium으로 반복. D는 이 데이터를 비트 단위로 재분석.
