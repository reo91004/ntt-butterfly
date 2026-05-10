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

Exp A canonical rerun과 동일하나 `--mode 0` (GS). 다른 모든 파라미터 같음:
N=20000, k=16, mode2=0 (Kyber), `a`는 0xCAFEBABE 입력 후 q로 reduction되어
1409가 FPGA에 주입, b TVLA fixed-vs-random.

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

canonical rerun 데이터 위치: `host/results/20260510_200722_exp_B2_kyber_gs_a_mod_N20k/`

legacy 데이터 위치: `host/results/20260510_183237_exp_B_kyber_gs_N20k/`

## 결과

| 지표 | CT (Exp A) | GS (Exp B) |
|---|---|---|
| Peak \|t\| | 90.321 @ sample 21 | **88.009 @ sample 24** |
| \|t\| > 4.5 통과 sample | 65 / 800 | 82 / 800 |
| Cluster 1 (양수 t) | 15-30 | 15-30 |
| Cluster 2 (음수 t) | 39-54 | 39-54 |

상위 10 (Exp B = GS):

```
순위  sample   t-stat
   1      24   +88.009
   2      21   +87.672
   3      22   +84.574
   4      18   +82.180
   5      27   +77.834
   6      19   +76.503
   7      25   +74.452
   8      45   -68.413
   9      30   +67.867
  10      51   -67.765
```

## 해석

### 모드 무관 누설

CT와 GS는 canonical input에서도 같은 큰 cluster 영역에서 누설:
- peak sample은 21 vs 24로 3 ADC sample 차이
- Peak 크기 차이 2.6% (90.3 vs 88.0)
- 동일한 두-클러스터 구조 (양수 15-30, 음수 39-54)
- 클러스터 경계 ±1 sample 이내

**결론**: 별도 모드 전용 cluster는 보이지 않고, 누설은 주로 **공유 datapath**
(multiplier, Montgomery 감산기, 출력 register) 에서 발생하는 것으로 해석된다. 다만
단일 알고리즘 구현과 직접 비교한 baseline은 없으므로 "mode mux 자체가 leak-clean"이라고
단정하지 않고, "추가 cluster가 관측되지 않음"으로 표현한다.

### 패턴이 그토록 비슷한 이유

두 모드의 *최종 출력*은 다르지만 (out1/out2가 다른 식으로 계산), 둘 다 비밀 의존
중간값을 같은 파이프라인 register들로 흘려보냄:
- `mul_s2 = m1_s1 * ref_zeta_s1`, 여기서 `m1_s1 = b` (CT) 또는 `(a−b) mod q` (GS)

두 경우 모두 S2 의 multiplier register update가 operand-dependent power를 누설.
차이는 multiplier에 들어가는 값 자체 (`b` vs `a−b`) 인데 `a`가 모든 trace에서 고정
이므로 b에 대한 의존성은 상수 offset 차이만 있음 — 누설이 b로 어떻게 스케일하는지는
변하지 않음.

### SCA 평가 측면 의미

이 결과는 통합 디자인에 **양면적 시사**:
- **공학적 관찰**: CT/GS 전환에서 별도 신규 cluster는 관측되지 않는다. 다만 분리 구현
  baseline이 없으므로 mode mux 자체를 "leak-clean"이라고 단정하지 않는다.
- **보안적 부정**: 누설이 모드와 무관하게 강함. "안전한 모드를 골라서 쓴다"는 회피책
  은 통하지 않음.

대응책의 의미: 보호해야 할 주요 지점은 두 모드 모두 공유 datapath에 있다.

## 파일

```
host/results/20260510_200722_exp_B2_kyber_gs_a_mod_N20k/
├── traces.npy
├── inputs.npz
├── metadata.json
├── tvla_t_stat.npy
└── tvla_plot.png
```
