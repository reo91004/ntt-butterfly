# 실험 B — Kyber GS-mode 비교

## 목적

같은 알고리즘 (Kyber) 안에서 **CT (Cooley-Tukey)** 와 **GS (Gentleman-Sande)** 모드의
누설을 비교. 두 모드는 ζ가 어느 operand에 곱해지는가만 다름:

- CT (`mode=1`): `out1 = (a + b·ζ) mod q,    out2 = (a − b·ζ) mod q`
- GS (`mode=0`): `out1 = (a + b)   mod q,    out2 = ((a − b)·ζ) mod q`

질문: 통합 로직 (mode mux) 이 **모드 의존적 누설**을 만드는가? 즉 CT와 GS가 별도의
하드웨어로 구현되었다면 없었을 누설이 mode 분기 때문에 추가로 생기는가?

## 가설

mode 분기 회로가 누설한다면 (예: `mode` 신호에 따라 다른 control path가 활성화되며
그 switch가 power로 보임) CT와 GS가 **다른** 누설 패턴을 보여야 함 — 다른 클러스터
위치, 강도, 부호 등. 공유 datapath만 누설한다면 패턴이 **동일**해야 함.

## 셋업

Exp A와 동일하나 `--mode 0` (GS). 다른 모든 파라미터 같음:
N=20000, k=16, mode2=0 (Kyber), `a`=0xCAFEBABE, b TVLA fixed-vs-random.

**중요**: seed=0xC0FFEE (default) 가 A와 B에서 동일 → b 시퀀스와 그룹 할당이 정확히
같음. **paired 비교**가 가능 — 정확히 같은 b 값을 두 모드에서 처리한 결과.

## 명령

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_B_kyber_gs_N20k \
    --mode 0 --mode2 0 --k 16 --samples 800 --no-program

python3 host/tvla.py host/results/<timestamp>_exp_B_kyber_gs_N20k/
```

데이터 위치: `host/results/20260510_183237_exp_B_kyber_gs_N20k/`

## 결과

| 지표 | CT (Exp A) | GS (Exp B) |
|---|---|---|
| Peak \|t\| | 91.506 @ sample 24 | **92.786 @ sample 24** |
| \|t\| > 4.5 통과 sample | 79 / 800 | 74 / 800 |
| Cluster 1 (양수 t) | 15-30 | 16-30 |
| Cluster 2 (음수 t) | 39-54 | 39-54 |

상위 10 (Exp B = GS):

```
순위  sample   t-stat
   1      24   +92.786
   2      21   +90.922
   3      22   +83.449
   4      27   +81.261
   5      18   +81.145
   6      25   +77.654
   7      19   +77.439
   8      30   +71.324
   9      51   -69.464
  10      45   -68.353
```

## 해석

### 모드 무관 누설

CT와 GS는 누설 패턴 수준에서 **통계적으로 구분 불가**:
- 같은 peak sample (24)
- Peak 크기 차이 1.4% (91.5 vs 92.8)
- 동일한 두-클러스터 구조 (양수 15-30, 음수 39-54)
- 클러스터 경계 ±1 sample 이내

**결론**: 통합 (mode mux) 자체는 추가 모드 의존적 누설을 만들지 *않음*. 누설은
**공유 datapath** (multiplier, Montgomery 감산기, 출력 register) 에서 발생.

### 패턴이 그토록 비슷한 이유

두 모드의 *최종 출력*은 다르지만 (out1/out2가 다른 식으로 계산), 둘 다 비밀 의존
중간값을 같은 파이프라인 register들로 흘려보냄:
- `mul_s2 = m1_s1 * ref_zeta_s1`, 여기서 `m1_s1 = b` (CT) 또는 `(a−b) mod q` (GS)

두 경우 모두 S2 의 multiplier register update가 operand 의존 Hamming weight를 누설.
차이는 multiplier에 들어가는 값 자체 (`b` vs `a−b`) 인데 `a`가 모든 trace에서 고정
이므로 b에 대한 의존성은 상수 offset 차이만 있음 — 누설이 b로 어떻게 스케일하는지는
변하지 않음.

### SCA 평가 측면 의미

이 결과는 통합 디자인에 **양면적 시사**:
- **공학적 양호**: mode mux 자체는 "leak-clean". 단일 모드 구현 (CT-only / GS-only)
  도 같은 누설 점을 노출했을 것.
- **보안적 부정**: 누설이 모드와 무관하게 강함. "안전한 모드를 골라서 쓴다"는 회피책
  은 통하지 않음.

대응책의 의미: CT 전용 마스킹과 GS 전용 마스킹을 따로 만들 필요 없음. 한 마스킹
스킴이 두 모드 모두에 적용 가능.

## 파일

```
host/results/20260510_183237_exp_B_kyber_gs_N20k/
├── traces.npy
├── inputs.npz
├── metadata.json
├── tvla_t_stat.npy
└── tvla_plot.png
```
