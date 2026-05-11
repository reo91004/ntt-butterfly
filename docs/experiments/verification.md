# 실험 정합성 검증 보고서 — corrected rerun

이 문서는 초기 A-E 실험을 재검토한 뒤 코드 수정, canonical input 재캡처, 재분석을 수행한
결과입니다.

## 수정 사항

1. `capture_traces.py`
   - `a`를 q로 reduction한 뒤 FPGA에 주입.
   - `inputs.npz`에 `a`(실제 주입값)와 `a_raw`(사용자 입력값)를 함께 저장.
   - metadata에 `a_raw`, `a_mod_q`, vary 대상(`b` 또는 `k`)을 명시.

2. `specific_tvla.py`
   - fixed-vs-random capture를 비트별로 분석할 때 기본적으로 random half만 사용.
   - fixed half가 섞여 생기던 false "all bits leak uniformly" 결론 제거.
   - 출력 파일명은 `spec_tvla_random_*`.

3. `cpa.py`
   - CT/GS mode별 leakage model 분리.
   - GS는 RTL의 `(a>=b) ? a-b : a+q-b` multiplier input과 정합.

## 새 실험 데이터

| 실험 | 결과 폴더 | 핵심 조건 |
|---|---|---|
| A2 | `20260510_200546_exp_A2_kyber_ct_a_mod_N20k` | Kyber CT, k=16 |
| B2 | `20260510_200722_exp_B2_kyber_gs_a_mod_N20k` | Kyber GS, k=16 |
| C1b | `20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k` | Dilithium CT, k=1 |
| C2b | `20260510_201434_exp_C2b_dil_gs_a_mod_k1_N20k` | Dilithium GS, k=1 |
| C-control | `20260510_200859_exp_C2_control_dil_ct_a_mod_k16_N20k` | Dilithium CT, k=16 |
| E2 | `20260510_201031_exp_E2_kyber_ct_cpa_a_mod_N20k` | Kyber CT CPA, vary k |

모든 TVLA rerun은 N=20000, seed=0xC0FFEE, internal trigger, capture fail=0입니다.
새 데이터의 `out1/out2`는 모두 q 범위 안에 들어와 RTL 산술 전제가 충족됩니다.

## TVLA 검증

| 실험 | peak \|t\| @ sample | \|t\| > 4.5 samples | 정합성 |
|---|---:|---:|---|
| A2 Kyber CT k=16 | 90.321 @ 21 | 65 / 800 | 누설 재현 |
| B2 Kyber GS k=16 | 88.009 @ 24 | 82 / 800 | 같은 cluster 영역 |
| C1b Dil CT k=1 | 93.866 @ 24 | 146 / 800 | 누설 재현 |
| C2b Dil GS k=1 | 96.174 @ 20 | 116 / 800 | 누설 재현 |
| C-control Dil CT k=16 | 98.126 @ 21 | 128 / 800 | Kyber 대비 더 넓은 window |

결론: canonical input 조건에서도 TVLA fail은 확실합니다. Dilithium은 Kyber보다 peak가
약간 높고, 임계 통과 sample 수가 더 많습니다.

## Bit-Specific TVLA 검증

corrected 분석은 random-b traces만 사용합니다.

| 데이터 | 임계 통과 bit 수 | 결론 |
|---|---:|---|
| Kyber CT k=16 | 4 / 12 | 일부 bit만 강함 |
| Kyber GS k=16 | 5 / 12 | 일부 bit만 강함 |
| Dilithium CT k=1 | 9 / 23 | 일부 bit만 강함 |
| Dilithium GS k=1 | 11 / 23 | 일부 bit만 강함 |
| Dilithium CT k=16 | 3 / 23 | 일부 bit만 강함 |

초기 결론인 "모든 사용 bit가 균등하게 누설되어 HW 모델을 확정"은 철회합니다. 현재
정합한 결론은 **operand-dependent leakage가 존재하지만, 단순 bit-uniform HW leakage로
확정되지는 않는다**입니다.

## CPA 검증

canonical CPA rerun:

| 분석 | winner | true rank | 해석 |
|---|---:|---:|---|
| focus sample 18 | 3153 | 1550 / 3329 | random 수준 |
| focus sample 21 | 1201 | 1829 / 3329 | random 수준 |

초기 CPA rank 120/3329는 legacy non-canonical `a` capture에서 나온 결과입니다. canonical
조건에서는 naive single-sample HW CPA로 후보 공간 축소가 확인되지 않았습니다.

## 전체 평가

| 항목 | corrected 평가 |
|---|---|
| Exp A | 정합. canonical input에서도 강한 TVLA 누설 |
| Exp B | 정합. CT/GS 모두 같은 cluster 영역에서 강한 누설 |
| Exp C | 정합. Dilithium은 Kyber보다 더 넓게 누설 |
| Exp D | 초기 결론 수정. random-only 분석에서 일부 bit만 임계 통과 |
| Exp E | 초기 exploitability 결론 수정. canonical naive CPA는 실패 |
| Exp F | normal capture localization 결론 수정. 마지막 `REG_B` write/input path가 강한 peak를 지배할 수 있음 |
| Exp G | preload/scrub으로 `REG_B` start 값을 fixed로 묶어도 `b_core`가 변하면 강한 TVLA peak 유지 |

**전반적 결론**: unified butterfly2는 canonical 입력 조건에서도 강한 입력 의존 전력 누설을
보이며 TVLA 기준으로 fail입니다. 다만 A-E의 강한 peak를 sample 위치만 보고 곧바로
multiplier/MR/S7 누설로 localize하면 안 된다는 Exp F의 경고는 여전히 유효합니다.
normal capture에서는 마지막 `REG_B` write/input path가 peak를 크게 지배할 수 있습니다.
그러나 Exp G에서 external `REG_B` start 값을 fixed로 scrub하고 내부 preload로만
`b_core`를 바꿔도 강한 peak가 남았으므로, 최신 결론은 **butterfly core/Montgomery/S7
이후 값 의존 누설도 실제로 존재한다**입니다. 공격 효율을 주장하려면 profiling/template,
다중 중간값 기반 재실험이 필요합니다.
