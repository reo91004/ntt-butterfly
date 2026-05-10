# 실험 D — 비트별 (specific) TVLA, corrected

## 목적

기존 TVLA (Exp A/B/C)는 "fixed b vs random b"를 비교했다. 비트별 TVLA는 여기서
한 단계 더 들어가 `b`의 각 비트 위치별로 trace를 다시 나눠 어떤 비트가 누설되는지
확인한다.

중요한 수정: fixed-vs-random capture 전체를 그대로 비트별로 나누면 fixed-b trace 절반이
각 비트 그룹 한쪽에 통째로 들어간다. 그러면 "bit 0/1 비교"가 아니라 원래의
fixed-vs-random 차이를 다시 보는 confound가 생긴다. 따라서 corrected Exp D는
`group == 1`인 random-b trace만 사용한다.

## 코드 수정

`host/specific_tvla.py` 기본 동작을 `--cohort auto`로 변경했다.

- `inputs.npz`에 fixed/random `group`이 있고 두 그룹이 모두 있으면 random-only 분석
- CPA처럼 group이 한쪽뿐인 데이터는 all traces 분석
- 출력 파일명은 `spec_tvla_random_*` 형태

```bash
python3 host/specific_tvla.py host/results/<exp_A2>/
python3 host/specific_tvla.py host/results/<exp_C1b>/
```

## 데이터

canonical rerun 데이터를 사용했다.

- Kyber CT: `host/results/20260510_200546_exp_A2_kyber_ct_a_mod_N20k/`
- Kyber GS: `host/results/20260510_200722_exp_B2_kyber_gs_a_mod_N20k/`
- Dilithium CT k=1: `host/results/20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k/`
- Dilithium GS k=1: `host/results/20260510_201434_exp_C2b_dil_gs_a_mod_k1_N20k/`
- Dilithium CT k=16: `host/results/20260510_200859_exp_C2_control_dil_ct_a_mod_k16_N20k/`

각 데이터는 N=20000 중 random half 9953 traces만 비트별 그룹화에 사용했다.

## 결과

### 요약

| 데이터 | 사용 비트 | 임계 통과 bit 수 | 가장 강한 bit |
|---|---:|---:|---|
| Kyber CT k=16 | 12 | 4 / 12 | bit10, \|t\|=11.877 @ sample 18 |
| Kyber GS k=16 | 12 | 5 / 12 | bit10, \|t\|=19.391 @ sample 12 |
| Dilithium CT k=1 | 23 | 9 / 23 | bit6, \|t\|=8.306 @ sample 26 |
| Dilithium GS k=1 | 23 | 11 / 23 | bit22, \|t\|=11.148 @ sample 14 |
| Dilithium CT k=16 | 23 | 3 / 23 | bit18, \|t\|=6.257 @ sample 19 |

### Kyber CT k=16

```
rank  bit   peak|t|   sample
  1    10    11.877      18
  2     9    11.630      18
  3    11     5.857      18
  4     7     5.711      15
```

### Dilithium CT k=1

```
rank  bit   peak|t|   sample
  1     6     8.306      26
  2    18     7.760      20
  3    22     6.893      12
  4    20     6.207      20
  5     4     5.877      21
  6     3     5.678      21
```

## 해석

초기 Exp D 문서는 전체 fixed-vs-random 데이터를 비트별로 재그룹화했고, 그 결과 Kyber
12 bits와 Dilithium 23 bits가 모두 큰 |t|로 누설되는 것처럼 보였다. corrected 분석에서는
그 결론이 유지되지 않는다.

- 누설은 여전히 존재한다.
- 하지만 모든 사용 bit가 균등하게 누설된다는 주장은 성립하지 않는다.
- 단순한 "HW 모델 확정" 대신, 현재 결론은 **특정 bit와 특정 pipeline sample에 집중되는
  operand-dependent leakage**다.
- fixed-vs-random TVLA의 큰 peak는 강력한 leakage detector이지만, 그것만으로 bit별
  leakage model을 확정하면 안 된다.

## 파일

각 입력 데이터 폴더에 다음 파일이 추가된다.

```
spec_tvla_random_bits.png
spec_tvla_random_summary.txt
spec_tvla_random_bit_XX_t.npy
```

legacy `spec_tvla_bits.png` / `spec_tvla_summary.txt`는 fixed half가 포함된 초기 분석 결과라
문서 결론에는 사용하지 않는다.
