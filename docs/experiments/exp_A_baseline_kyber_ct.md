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
| `a` | 0xCAFEBABE (모든 trace에서 고정) |
| `b` | TVLA 스타일: 50% 고정 (0x12345678 % 3329 = 791), 50% 균등 랜덤 [0, 3329) |
| N | 20000 traces |
| Sample window | 800 ADC samples |
| 하드웨어 | CW305 + Husky-Plus, ADC 192 MHz |

## 명령

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_A_kyber_ct_N20k \
    --mode 1 --mode2 0 --k 16 --samples 800 --no-program

python3 host/tvla.py host/results/<timestamp>_exp_A_kyber_ct_N20k/
```

데이터 위치: `host/results/20260510_183101_exp_A_kyber_ct_N20k/`

## 결과

| 지표 | 값 |
|---|---|
| 캡처 실패 | 0 / 20000 |
| 캡처 속도 | ~272 trace/s |
| Peak \|t\| | **91.506 @ sample 24** |
| \|t\| > 4.5 통과 sample 수 | 79 / 800 |
| Cluster 1 (양수 t) | sample 15–30, peak +91.5 |
| Cluster 2 (음수 t) | sample 39–54, peak −65.9 |

상위 10개 누설 sample (|t| 기준):

```
순위  sample   t-stat
   1      24   +91.506
   2      21   +90.710
   3      18   +84.629
   4      22   +79.925
   5      27   +77.993
   6      19   +76.196
   7      25   +71.996
   8      30   +65.955
   9      45   -65.917
  10      51   -65.805
```

## 해석

### 1. 스케일링 검증 통과

```
N=2000  → peak |t| = 29.267
N=20000 → peak |t| = 91.506
  실측 비율 = 91.506 / 29.267 = 3.13
  이론값  √(20000/2000) = √10 ≈ 3.16
```

비율이 √N과 1% 이내 일치. **누설은 통계적으로 진짜이고, 결정론적이며, 우연이 아님**.

### 2. 누설 위치

t값 부호가 반대인 두 클러스터:

- **Cluster 1 — sample 15–30 (양수 t)**: 파이프라인 cycle C8–C15 (Mont S4 / 최종
  S7 / busy idle 구간)에 해당. 이 cycle을 흐르는 값은 `t_after_mr` (Montgomery 후
  값) 와 최종 out1/out2 register. 양수 t = "고정-b traces가 랜덤-b traces보다 평균
  전력이 HIGH" — 고정 b 값이 multiplier 출력에서 평균보다 높은 Hamming weight를
  만들기 때문이라는 가설과 일치.

- **Cluster 2 — sample 39–54 (음수 t)**: cycle C20–C27, butterfly 후 idle 영역
  깊숙이. 결과가 read_data combinational mux로 fanout되는 시점. 부호가 뒤집힌 이유:
  결과값이 register들 간 분배되며 안정화되는 과정에서 고정-b 의 정상 상태가
  랜덤-b의 평균과 다르기 때문.

### 3. "secret" 이 무엇인가

TVLA 그룹화는 **`b`** (butterfly 두 번째 operand) 에 따라 했음. 누설은 *b의 함수*.
파이프라인 위치 기준 가장 가능성 높은 중간값:
- `mul_s2 = m1_s1 * ref_zeta_s1` (64-bit multiplier 출력, zeta 고정이므로 b에 선형
  의존)
- `t_after_mr` (Montgomery-reduced 출력, Kyber 범위 [0, 3328])
- `out1, out2` (최종 모듈러-q 결과)

Exp D (비트별 TVLA) 에 따르면 누설은 **multiplier 출력의 Hamming weight**와 일치.
특정 bit이나 Hamming distance가 아님.

## 파일

```
host/results/20260510_183101_exp_A_kyber_ct_N20k/
├── traces.npy       (20000, 800) float32  — raw ADC
├── inputs.npz       per-trace a, b, k, mode, mode2, group, out1, out2
├── metadata.json    실험 전체 기록 (scope settings, bitfile MD5)
├── tvla_t_stat.npy  (800,) sample별 Welch's t
├── tvla_plot.png    ±4.5 임계 표시된 시각화
└── spec_tvla_*.npy/png  (Exp D 에서 추가)
```

## 비교 기준 역할

이 실험이 B, C, D 의 **앵커**. B는 GS 모드로 반복 (control: 같은 알고리즘, 다른
방향). C는 Dilithium으로 반복. D는 이 데이터를 비트 단위로 재분석.
