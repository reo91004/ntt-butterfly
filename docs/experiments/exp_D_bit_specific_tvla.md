# 실험 D — 비트별 (specific) TVLA

## 목적

기존 TVLA (Exp A, C)가 "fixed b vs random b"라는 거시적 그룹을 비교했다면, 이번엔
**`b`의 각 비트 위치를 따로 그룹화**해서 어떤 비트가 누설되는지 분리.

이것이 중요한 이유:
- **HW (Hamming-weight) 누설**이라면: 모든 사용 비트가 거의 균등하게 누설 (각
  비트가 HW에 1만큼 기여하므로)
- **specific-bit 누설**이라면: 특정 비트 (예: MSB, 또는 multiplier 부호 비트) 만
  강하게 누설하고 나머지는 약함
- **HD (Hamming-distance) 누설**이라면: 이전 register 상태에 의존, 비트 패턴은
  레지스터 갱신 시점과 결합돼서 비균등

이 분류는 적절한 방어법 (HW: 부울 마스킹, HD: 복합 마스킹) 을 결정하는 데 필수.

## 가설

지금까지 TVLA 결과 (peak |t| ~91 — 매우 강함, 위치도 구분 명확) 를 가장 단순하게
설명하는 모델은 HW. 비트별 TVLA에서 모든 사용 비트가 비슷한 |t| 강도로 누설되어야
HW 모델이 검증됨.

## 셋업

**별도 캡처 없음** — Exp A (Kyber) 와 C1 (Dilithium) 의 기존 데이터를 재분석.

각 trace의 `b` 값을 비트 i (i=0..31) 로 분리:
- 그룹 A: `(b >> i) & 1 == 0` 인 trace
- 그룹 B: `(b >> i) & 1 == 1` 인 trace
- Welch's t-test 수행, sample별 |t| 측정, peak 보고

`b ∈ [0, q)` 범위 제약 때문에 상위 비트들은 항상 0 → 그룹 B 비어 → "too unbalanced"
로 skip. Kyber에서 비트 12+ skip, Dilithium에서 비트 23+ skip.

## 명령

```bash
python3 host/specific_tvla.py host/results/<exp_A>/
python3 host/specific_tvla.py host/results/<exp_C1>/
```

스크립트가 같은 결과 폴더에 다음을 추가:
- `spec_tvla_bits.png` — 비트 인덱스별 peak |t| 막대 그래프
- `spec_tvla_summary.txt` — 정렬된 텍스트 요약
- `spec_tvla_bit_<i>_t.npy` — top 8 누설 비트의 sample별 t-trace

## 결과

### Kyber (q=3329, b는 12-bit 범위)

```
bit  peak |t|   peak sample   group sizes (A:0, B:1)
  0   70.359        21           4992 vs 15008
  1   69.095        24           4921 vs 15079
  2   69.790        24           4966 vs 15034
  3   68.556        24          15004 vs  4996
  4   69.986        24           5006 vs 14994
  5   70.204        24          14886 vs  5114
  6   69.131        24          14951 vs  5049
  7   70.401        24          14940 vs  5060
  8   71.620        24           5340 vs 14660
  9   75.491        24           5360 vs 14640    ← 최대
 10   65.856        24          16051 vs  3949
 11   65.280        24          16216 vs  3784
 12-31  too unbalanced (b 12-bit 이내 → bit 12+ 항상 0)
```

→ **12개 사용 비트 모두 누설** (|t| > 4.5).
→ peak |t| 분포 65–76: **대체로 균등**, 최댓값/최솟값 차이 16% 정도.
→ peak sample은 모든 비트에서 거의 24 — **단일 leakage point**.

### Dilithium (q=8380417, b는 23-bit 범위)

```
bit  peak |t|   peak sample
  0   74.589        21
  1   74.319        21
  2   73.730        29
  3   75.256        21
  4   75.948        21
  5   74.484        21
  6   76.619        21
  7   75.417        24
  8   74.075        21
  9   72.674        24
 10   73.518        21
 11   73.695        21
 12   73.884        21
 13   73.997        21
 14   72.448        21
 15   74.445        21
 16   72.106        21
 17   74.801        21
 18   76.214        21
 19   73.350        24
 20   75.873        21
 21   73.655        21
 22   73.099        21
 23-31  too unbalanced
```

→ **23개 사용 비트 모두 누설** (|t| > 4.5).
→ peak |t| 분포 72–77: **매우 균등** (편차 7% 이내).
→ peak sample은 거의 21에 집중.

## 해석

### 1. HW (Hamming weight) 누설 모델 강력 검증

비트별 |t|가 균등 분포 (Kyber 65-76, Dilithium 72-77) 한다는 것은 각 비트의 누설
기여도가 비슷하다는 의미. HW 모델 (각 비트 = HW에 +1) 이 정확히 이 패턴을 예측.

만약 일부 비트만 누설했다면 |t| 분포가 한두 봉우리로 치솟고 나머지는 임계 이하여야
함. **그렇지 않음**.

### 2. 단일 leakage point

거의 모든 비트가 같은 sample (Kyber: 24, Dilithium: 21) 에서 peak. 즉 **하나의
register update 시점** 에서 b의 모든 비트가 한 번에 노출됨. multiplier 출력
register `mul_s2` 또는 그 직후 stage register가 전체 b 정보를 들고 있다는 뜻.

### 3. Kyber와 Dilithium의 미세 차이

- Kyber에서 bit 9가 가장 높은 누설 (|t| = 75.5). 평균 (~70) 보다 7% 위.
- Dilithium은 비트 폭만 크고 강도 분포는 더 균등.

비트 9가 약간 튀는 이유는 q=3329의 비트 패턴 특성 때문 (3329 = 2^11 + 2^10 + 2^7 +
2^0 + 2^... 등 여러 비트 활성화). modulo 연산이 상위 비트와 하위 비트를 섞는
방식이 미세하게 비균등을 만듦.

### 4. 방어 설계 영향

HW 누설이 확정 → **부울 마스킹** (boolean masking) 이 적합한 대응책. 각 비트를
랜덤 share 두 개로 분할하면 HW가 비밀과 무관해짐.

HD 누설이라면 마스킹 share 간 transition도 보호해야 해서 더 복잡한데 (산술 마스킹
혹은 latch 기반 보호), HW 모델이라 단순한 share-only 마스킹으로 충분.

### 5. caveat: 그룹 균형

bit 11에서 그룹 비율이 16216:3784 (≈ 4:1). t-test는 균형이 안 맞아도 동작하지만
검출력이 낮아짐. 그래도 |t| = 65.3 으로 임계값 14배 위 → 충분.

상위 비트 (12+ Kyber, 23+ Dilithium) 는 항상 0이므로 **이 비트들이 누설될 가능성은
원천적으로 측정 불가** — 하지만 HW 모델 가정 하에서, 이 비트들도 "값이 0이라는
정보"는 항상 0 비트로 누설된다 (즉 HW에 0을 기여). 별 의미 없는 정보.

## 파일

각 입력 데이터 폴더에 다음 추가:
```
spec_tvla_bits.png       비트별 peak |t| 막대 그래프
spec_tvla_summary.txt    랭킹 텍스트
spec_tvla_bit_XX_t.npy   top 8 비트의 sample별 t-trace (재분석용)
```

## 다음 단계 함의

- HW 누설 검증됨 → CPA 시도 (Exp E) 정당화
- "어떤 비트가 누설되는지"는 정해졌으니, "그 비트로 secret을 얼마나 빠르게
  복구할 수 있는지" 가 다음 질문 → Exp E
