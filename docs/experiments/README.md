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
| [A](exp_A_baseline_kyber_ct.md) | 대용량 베이스라인 (Kyber CT) | yes | b varies | canonical rerun peak \|t\|=90.3 @ sample 21, 65/800 samples 누설 |
| [B](exp_B_kyber_gs.md) | Kyber GS 모드 비교 | yes | b varies | canonical rerun peak \|t\|=88.0 @ sample 24, CT와 같은 cluster 영역 |
| [C](exp_C_dilithium.md) | Dilithium CT/GS + control | yes | b varies | canonical rerun peak \|t\|=93.9-98.1, Kyber보다 더 넓은 누설 window |
| [D](exp_D_bit_specific_tvla.md) | 비트별 TVLA | (A/B/C 데이터 재분석) | random-b only | fixed half 제거 후 Kyber 4-5 bits, Dilithium 3-11 bits만 임계 통과 — "전 bit 균등 HW" 결론 철회 |
| [E](exp_E_cpa.md) | CPA — 공격 가능성 점검 | yes (vary k) | b fixed=1291 | canonical rerun에서 true rank 1550/1829 수준 — naive HW CPA exploitable 결론 미확인 |
| [F](exp_F_input_write_isolation.md) | 입력 write path 분리 | temporary variants | b write varies | core/S7를 끊어도 peak 유지, arm 직전 fixed B scrub 시 peak 소멸 — 현재 dominant peak는 `REG_B` write/input path |

부록: [검증 보고서](verification.md) — Sequential thinking으로 실험 정합성 재검증.

---

## 무엇을 검증했는가

unified butterfly2 디자인은 Kyber와 Dilithium의 NTT butterfly를 단일 mode-multiplexed
datapath에 통합한 구조입니다. 핵심 연구 질문: 이 통합이 **분리된 단일 알고리즘 구현**
에서는 없었을 부채널 노출을 만들어내는가?

**현재까지의 답**: canonical input (`a,b < q`) 조건에서도 unified datapath는
**입력에 강하게 의존하는 전력 정보를 새고 있음**:

- N=20000 trace에서 TVLA peak |t| ≈ 88-98 도달. 표준 임계값 4.5를 압도. butterfly의
  첫 몇 cycle 안에서 즉시 검출됨.
- 누설은 **알고리즘별로 강도가 다름** (Dilithium > Kyber, 더 넓은 operand가 더 많은
  bit-flip을 만들어서) **하지만 위치는 동일** — 4가지 알고리즘×모드 조합에서 누설
  파이프라인 stage가 같음.
- A-E만 보면 peak 위치가 S7/post-result window와 겹쳐 core output 누설처럼 보인다.
  그러나 [F](exp_F_input_write_isolation.md)의 isolation bitstream 결과, 현재 capture
  protocol에서 dominant peak는 **마지막 `REG_B` write/input path 상태**가 지배한다.
  따라서 A-E의 TVLA fail은 유효하지만, 그 peak를 곧바로 multiplier/MR/S7 누설로
  localize하면 안 된다.

**실제 공격 가능성**: legacy capture (`a=0xCAFEBABE`를 q로 줄이지 않고 주입) 에서는
단순 HW CPA가 후보 공간을 줄였지만, canonical rerun에서는 true rank가 random guess와
비슷해졌습니다. 따라서 현재 문서의 보수적 결론은 **TVLA fail은 확실하나 naive CPA
복구 가능성은 미확인**입니다. 공격 효율 평가는 profiling/template 또는 다중 모델
재실험이 필요합니다.

---

## 모든 실험 공통 파라미터

아래 표는 이 문서에 기록된 canonical 결과의 원래 측정 조건입니다. 새 PC에서
CW-Lite/Pro로 재현할 때는 ADC MHz가 달라지므로 바로 아래 “재현 방법”의
`--sample-cycles` 예시처럼 target cycle 기준으로 캡처 길이를 맞추세요.

| 항목 | 값 | 비고 |
|---|---|---|
| 하드웨어 | CW305 + ChipWhisperer-Husky-Plus | 20-pin connector, X4 SMA on Vcc-int |
| Bitstream | `bitstream/cw305_unified_butterfly2_top_v4.bit` | wrapper의 `tio_trigger = busy_reg` 사용 |
| 타겟 클럭 | 96 MHz (CW305 usb_clk) | `scope.clock.freq_ctr` 측정값 |
| ADC | 192 MHz (Husky `clkgen_freq=96e6 adc_mul=2`) | 타겟 cycle당 2 ADC sample |
| Trigger | `internal` (busy_reg → tio_trigger → scope tio4) | sub-cycle 정렬 |
| Sample window | 800 samples | core 결과 + post-result window 포함 |
| RNG seed | 0xC0FFEE | A/B/C에서 동일 — paired 비교 가능 |
| Host input normalization | `a`와 `b_fixed`를 q로 reduction 후 주입 | RTL의 butterfly 산술 전제 (`a,b < q`) 와 정합 |

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
| C10+ | core output 안정화 / post-result window, busy_reg는 CAPTURE_DELAY까지 유지 | 18+ |
| C74 근처 | wrapper가 out1_wire/out2_wire를 readback register로 latch, done=1, trigger 하강 | ~146 |

→ A-E의 TVLA peak이 sample 18-30에 떨어지는 것은 S7/post-result window와 시간상
겹친다. 다만 Exp F 이후 이 위치만으로 core output 누설이라고 단정하지 않는다.
현재 capture loop에서는 `REG_B` write 직후 scope를 arm하므로, 마지막 B write/input
path 상태가 같은 window에 강하게 남을 수 있다.

주의: 위 sample 번호는 Husky/Husky-Plus `adc_mul=2` 기준입니다. CW-Lite/Pro
`adc_mul=1` 재현에서는 같은 하드웨어 cycle이 대략 절반의 sample index에 나타납니다.
서로 다른 scope 결과를 비교할 때는 `metadata.json`의 `samples_per_target_cycle`로
cycle index를 환산하세요.

---

## 재현 방법

각 실험 문서가 정확한 명령을 명시. 공통 요건은 sca-py 가상환경 (`pyenv activate sca`)
+ `chipwhisperer numpy matplotlib`, 그리고 CW305 + 지원되는 CW scope
(Husky/Husky-Plus/Lite/Pro) 하드웨어 연결.

CW-Lite/Pro 재현 예시:

```bash
python3 host/diag_trigger.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --scope-type lite --adc-mul 1 --samples 800 --exclude-scope-sn none

python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --scope-type lite --adc-mul 1 --sample-cycles 400 \
    --num-traces 2000 \
    --label kyber_ct_lite_repro \
    --mode 1 --mode2 0 --k 16 --exclude-scope-sn none
```

Husky/Husky-Plus는 `--adc-mul 0`(auto)에서 2 sample/cycle, CW-Lite/Pro는 1
sample/cycle입니다. `metadata.json`에 measured target MHz, estimated ADC MHz,
samples-per-target-cycle이 저장됩니다.

`host/results/<timestamp>_<label>/` 폴더 안에 다음이 저장됨:
- `traces.npy` — raw ADC traces (N, samples) float32
- `inputs.npz` — per-trace a, a_raw, b, k, mode, mode2, group, out1, out2
- `metadata.json` — 실험 조건, scope 설정, bitfile MD5
- `tvla_t_stat.npy`, `tvla_plot.png` — 분석 결과 (재생 가능)
- (Exp D) `spec_tvla_random_*.npy`, `spec_tvla_random_bits.png`
- (Exp E) `cpa_scores.npy`, `cpa_winning_corr.npy`, `cpa_plot.png`
