# 부채널 실험 — 인덱스

이 폴더는 unified butterfly2 SCA 플랫폼에서 수행한 실험들을 정리한 것입니다. 각
실험 문서는 목적, 셋업, 명령, 결과, 해석을 포함하며 사전 지식 없이도 읽을 수
있도록 작성되었습니다.

> **처음 보시는 분이라면** [../leakage_explained.md](../leakage_explained.md) 부터
> 읽으세요 — 부채널 공격이 무엇인지부터 이 디자인의 누설점이 정확히 어디인지까지
> 차근차근 설명합니다. 그 다음 아래 각 실험 문서로 넘어가세요.

실제 데이터는 `host/results/<timestamp>_<label>/` 에 저장되어 있고, 각 실험 문서가
관련 timestamp를 가리킵니다.

---

## 한눈에 보기

| 실험 | 주제 | bitstream 동일? | secret? | 핵심 결과 |
|---|---|---|---|---|
| [A](exp_A_baseline_kyber_ct.md) | 대용량 베이스라인 (Kyber CT) | yes | b varies | peak \|t\|=91.5, sample 16-30 (cluster1) + 39-54 (cluster2) 누설 검출 |
| [B](exp_B_kyber_gs.md) | Kyber GS 모드 비교 | yes | b varies | peak \|t\|=92.8, **CT와 동일한 패턴** — mode-dispatch가 아닌 공유 datapath 누설 |
| [C](exp_C_dilithium.md) | Dilithium CT/GS + control | yes | b varies | k=16에서 peak \|t\|=101.9 (Kyber 91.5 대비 ↑), **Dilithium이 더 누설** — 더 넓은 operand 폭 영향 |
| [D](exp_D_bit_specific_tvla.md) | 비트별 TVLA | (A 데이터 재분석) | b varies | **Kyber 12 used bits + Dilithium 23 used bits 모두 누설** — Hamming-weight 모델 강력히 시사 |
| [E](exp_E_cpa.md) | CPA — 실제 비밀 복구 | yes (vary k) | b fixed=1291 | True secret rank 120/3329 (top 3.6%) — search space 30× 축소, 단일 sample top-1 복구는 모델 한계로 미달 |

부록: [검증 보고서](verification.md) — Sequential thinking으로 5개 실험 정합성 재검증.

---

## 무엇을 검증했는가

unified butterfly2 디자인은 Kyber와 Dilithium의 NTT butterfly를 단일 mode-multiplexed
datapath에 통합한 구조입니다. 핵심 연구 질문: 이 통합이 **분리된 단일 알고리즘 구현**
에서는 없었을 부채널 노출을 만들어내는가?

**현재까지의 답**: unified datapath는 **입력에 강하게 의존하는 전력 정보를 새고 있음**:

- N=20000 trace에서 TVLA peak |t| ≈ 90+ 도달. 표준 임계값 4.5를 압도. butterfly의
  첫 몇 cycle 안에서 즉시 검출됨.
- 누설은 **알고리즘별로 강도가 다름** (Dilithium > Kyber, 더 넓은 operand가 더 많은
  bit-flip을 만들어서) **하지만 위치는 동일** — 4가지 알고리즘×모드 조합에서 누설
  파이프라인 stage가 같음.
- 누설 패턴은 **multiplier 출력 + Montgomery 후반부 + 최종 출력 register의
  Hamming-weight 누설**과 일치. 두 클러스터로 분리:
  - sample 16-30: 파이프라인이 출력 register에 도달하기까지의 영역
  - sample 39-54: 출력값이 read-mux로 fanout되는 영역

**실제 공격 가능성**: 교과서적인 Hamming-weight CPA를 단일 sample에 적용하면 Kyber의
3329개 후보 secret을 top 3.6%로 좁힘 (search space 30× 축소). 완전 복구에는 못
이르렀지만 **누설이 원리적으로 exploitable함은 확인**. 프로파일 기반 attack
(template) 으로는 거의 확실히 성공 가능.

---

## 모든 실험 공통 파라미터

| 항목 | 값 | 비고 |
|---|---|---|
| 하드웨어 | CW305 + ChipWhisperer-Husky-Plus | 20-pin connector, X4 SMA on Vcc-int |
| Bitstream | `bitstream/cw305_unified_butterfly2_top_v4.bit` | wrapper의 `tio_trigger = busy_reg` 사용 |
| 타겟 클럭 | 96 MHz (CW305 usb_clk) | `scope.clock.freq_ctr` 측정값 |
| ADC | 192 MHz (Husky `clkgen_freq=96e6 adc_mul=2`) | 타겟 cycle당 2 ADC sample |
| Trigger | `internal` (busy_reg → tio_trigger → scope tio4) | sub-cycle 정렬 |
| Sample window | 800 samples | butterfly 전체 + post-pipeline idle 포함 |
| RNG seed | 0xC0FFEE | A/B/C에서 동일 — paired 비교 가능 |

## 파이프라인 매핑 (sample → cycle)

wrapper가 `tio_trigger = busy_reg`로 구동. host의 `REG_STATUS=0x01` 쓰기 1 cycle 후
trigger 상승. ADC가 타겟 클럭의 2배:

| Cycle | 발생 동작 | ADC samples |
|---|---|---|
| C1 | busy_reg=1, a_core/b_core/k_core 갱신 | 0–1 |
| C2 | top-level a_r/b_r 갱신, ROM 출력 ref_zeta 유효 | 2–3 |
| C3 | **S1**: pre-mul mux + (a−b) mod q register | 4–5 |
| C4 | **S2: 32×32 multiplier 출력 `mul_s2`** ← b·ζ 등장 | 6–7 |
| C5 | Mont S1: T·QPRIME mod 2³² | 8–9 |
| C6 | Mont S2: m·q (64-bit) | 10–11 |
| C7 | Mont S3: 65-bit 덧셈, 상위 32 | 12–13 |
| C8 | Mont S4: final correction → t_after_mr | 14–15 |
| C9 | **S7**: 최종 add/sub register out1/out2 | 16–17 |
| C10+ | post-pipeline idle, busy_reg는 wait_count==72까지 유지 | 18+ |

→ TVLA peak이 sample 18-30에 떨어진다는 것은 **S7 최종 출력 register 갱신 직후 ~
busy idle 구간**에 누설이 집중된다는 뜻. cluster 39-54 (음수 t)는 출력값이
read_mux로 fanout되며 register 안정화되는 영역.

---

## 재현 방법

각 실험 문서가 정확한 명령을 명시. 공통 요건은 sca-py 가상환경 (`pyenv activate sca`)
+ `chipwhisperer numpy matplotlib`, 그리고 CW305 + Husky-Plus 하드웨어 연결.

`host/results/<timestamp>_<label>/` 폴더 안에 다음이 저장됨:
- `traces.npy` — raw ADC traces (N, samples) float32
- `inputs.npz` — per-trace a, b, k, mode, mode2, group, out1, out2
- `metadata.json` — 실험 조건, scope 설정, bitfile MD5
- `tvla_t_stat.npy`, `tvla_plot.png` — 분석 결과 (재생 가능)
- (Exp D) `spec_tvla_*.npy`, `spec_tvla_bits.png`
- (Exp E) `cpa_scores.npy`, `cpa_winning_corr.npy`, `cpa_plot.png`
