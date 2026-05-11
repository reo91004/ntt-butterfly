# 실험 F — 입력 write path 누설 분리

## 목적

기존 A-E 실험은 fixed-vs-random `b` TVLA에서 큰 peak를 보였고, sample 위치만 보면
Montgomery 후반/S7/post-result window와 겹쳤다. 그래서 처음에는 강한 누설점을
`mul_s2` 이후 값이 final `out1/out2` register와 fanout에 도달한 직후로 해석했다.

하지만 그 해석은 "sample 위치"에 근거한 가설이었다. 이 실험의 목적은 그 가설을
하드웨어 변형으로 검증하는 것이다.

질문:

- S7 correction 조건문 자체가 누설인가?
- final output register/fanout이 필수 원인인가?
- multiplier/MR datapath가 필수 원인인가?
- 아니면 capture 직전 `REG_B` write/input path가 TVLA를 지배하는가?

## 공통 조건

| 항목 | 값 |
|---|---|
| 장비 | CW305 + Husky-Plus |
| Scope serial | `50203220573555303230353232313036` |
| Target serial | `50203220535035313230303139313033` |
| Target clock | 96 MHz, measured about 95.999 MHz |
| ADC | Husky-Plus auto, 2 samples/target cycle |
| Capture | internal trigger, `sample_cycles=120`, 240 ADC samples |
| Trace 수 | 각 변형 N=3000 |
| TVLA | fixed `b=0x12345678 % q = 791` vs random `b in [0,q)` |
| Mode | Kyber CT, `mode=1`, `mode2=0`, `k=16` |

각 변형은 임시 RTL/host patch로 빌드/측정했고, 최종적으로 모든 patch는 되돌렸다.
결과 폴더는 ignored 경로인 `host/results/` 아래에만 남는다.

## 결과 요약

| ID | 변형 | 결과 폴더 | peak |
|---|---|---|---:|
| F1 | baseline current bitstream | `20260511_170524_exp_F1_baseline_current_N3k` | `|t|=33.65 @ s20` |
| F2 | S7 modular correction 제거 | `20260511_170711_exp_F2_s7_no_correction_N3k` | `|t|=34.88 @ s21` |
| F3/F3b | `out1/out2=0` | `20260511_170902_*`, `20260511_170950_*` | 무효: trace rail saturation |
| F4 | `out1/out2`를 secret-independent dummy toggle로 교체, core는 동작 | `20260511_171339_exp_F4_s7_dummy_output_N3k` | `|t|=35.07 @ s21` |
| F5 | core `.b=0`, `b_core` latch는 보존 | `20260511_171640_exp_F5_bcore_only_core_b_zero_N3k` | `|t|=35.20 @ s21` |
| F6 | `b_core=0`, core `.b=0`, `b_shadow`만 random | `20260511_171848_exp_F6_bshadow_random_bcore_zero_N3k` | `|t|=33.77 @ s20` |
| F7 | group label은 fixed/random이지만 실제 FPGA `b` write는 항상 fixed | `20260511_172039_exp_F7_negative_groups_random_b_write_constant_N3k` | `|t|=3.27`, no leakage |
| F8 | `b_shadow` 보존, `REG_B` readback mux는 constant | `20260511_172312_exp_F8_bshadow_preserved_b_readback_const_N3k` | `|t|=34.53 @ s21` |
| F9 | `b_shadow`도 netlist에서 제거되게 둠, `REG_B` readback constant | `20260511_172503_exp_F9_bshadow_swept_b_readback_const_N3k` | `|t|=33.83 @ s20` |
| F10 | F9 + write 후 arm 전 2 ms delay | `20260511_172642_exp_F10_prearm_delay2ms_f9_N3k` | `|t|=34.32 @ s21` |
| F11 | random B write 후 arm 직전 fixed B로 scrub | `20260511_172900_exp_F11_random_b_then_fixed_b_scrub_f9_N3k` | `|t|=2.63`, no leakage |

모든 유효 trace는 rail saturation이 없었다. F3/F3b만 analog operating point가 깨져
판정에서 제외했다.

## F11 재현 명령

현재 `host/capture_traces.py`에는 F11을 재현하기 위한 host-side load policy가 들어 있다.
이 실험은 RTL을 바꾸지 않고, trace마다 다음 순서를 강제한다.

1. TVLA group에 맞는 logical `b`를 `REG_B`에 먼저 쓴다.
2. scope를 arm하기 직전 `REG_B`를 fixed scrub 값으로 다시 쓴다.
3. start register를 써서 internal trigger를 발생시킨다.

즉 `inputs.npz` 안에서 `b`는 TVLA group용 logical 값이고, `b_effective_start`가 실제
start 시점에 core가 보게 되는 값이다. F11이 정합하려면 `b_first_write`는 fixed/random으로
갈라지고, `b_effective_start`는 전 trace에서 하나의 fixed 값이어야 한다.

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_F11_random_b_then_fixed_b_scrub_repro_N3k \
    --num-traces 3000 \
    --sample-cycles 120 \
    --trigger-mode internal \
    --mode 1 \
    --mode2 0 \
    --k 16 \
    --seed 0xC0FFEE \
    --b-fixed 0x12345678 \
    --b-load-policy random-then-scrub \
    --b-scrub-value 0x12345678

python3 host/tvla.py host/results/<timestamp>_exp_F11_random_b_then_fixed_b_scrub_repro_N3k
```

### 2026-05-11 재현 결과

같은 bitstream, 같은 seed, 같은 trace 수로 positive control과 F11을 연속 측정했다.

| Run | Load policy | Result dir | TVLA 결과 | 입력 검산 |
|---|---|---|---:|---|
| positive control | `normal` | `20260511_175513_exp_F11_positive_control_normal_N3k` | `|t|=34.841 @ s21`, 43/240 samples fail | `b == b_first_write == b_effective_start`, output unique 1208 |
| F11 repro | `random-then-scrub` | `20260511_175422_exp_F11_random_b_then_fixed_b_scrub_repro_N3k` | `|t|=2.957 @ s206`, 0/240 samples fail | `b == b_first_write`, `b_effective_start == 791` for all traces, output unique 1 |

따라서 F11 no-leak 결과는 장비/분석 실패가 아니다. 동일 세팅에서 normal load는 즉시
sample 21 peak를 재현하고, 마지막 `REG_B` write만 fixed scrub으로 바꾸면 peak가 사라진다.

## 핵심 판정

### 1. S7 correction 조건문은 주 원인이 아니다

F2에서 final modular correction 조건을 제거했는데 peak가 baseline과 같은 크기로
남았다. 따라서 `out1_wide >= q` 또는 `a_aligned >= m2_align` 같은 final 조건문 자체가
강한 TVLA의 1차 원인이라는 해석은 맞지 않다.

### 2. final `out1/out2` register/fanout도 필수 원인이 아니다

F4에서 `out1/out2`를 secret-independent dummy toggle로 바꿨지만 peak가 그대로 남았다.
따라서 현재 capture protocol에서 보이는 강한 s20대 peak는 final result register가
반드시 있어야 생기는 누설이 아니다.

### 3. multiplier/MR datapath도 이 peak의 필요조건이 아니다

F5/F6에서 core `.b`와 `b_core`를 constant로 끊어도 peak가 유지됐다. 따라서 현재
관측되는 강한 TVLA는 arithmetic core 내부의 `mul_s2`, Montgomery, S7만으로 설명할 수
없다.

### 4. 분석 artifact도 아니다

F7에서 fixed/random group label은 그대로 유지했지만 실제 FPGA로 쓰는 `b` 값을 constant로
만들자 peak가 사라졌다. 즉 단순한 group ordering, 시간 drift, TVLA 코드 오류가 아니다.
실제 FPGA로 전달되는 `REG_B` write 값이 원인이다.

### 5. `b_shadow` readback/fanout도 충분한 설명이 아니다

F8에서 `REG_B` readback mux를 constant로 끊어도 peak가 남았다. F9에서는 Vivado
implemented netlist에서 `b_shadow` cell이 0개임을 확인했는데도 random B write에서 peak가
남았다. 그래서 `b_shadow` FF bank나 readback mux만이 원인이라고도 말할 수 없다.

### 6. 현재 dominant leakage는 `REG_B` write/input path 상태다

F11이 결정적이다. random B를 먼저 써도, arm 직전에 `REG_B`를 fixed value로 한 번 더
덮어쓰면 TVLA peak가 사라졌다. 따라서 지금 capture protocol에서 보이는 강한 s20대 peak는
butterfly arithmetic 결과보다 **마지막 `REG_B` write/input path 상태**에 지배된다.

## 이전 해석을 어떻게 고쳐야 하나

예전 설명:

> peak sample 20-24가 S7/post-result window에 있으므로 final out register/fanout이 주
> 누출점이다.

수정된 설명:

> peak sample 20-24가 S7/post-result window와 겹치는 것은 맞지만, isolation bitstream을
> 돌려보면 그 peak는 core arithmetic 없이도 유지된다. 현재 capture loop가 `REG_B` write
> 직후 scope를 arm하고 start를 걸기 때문에, 마지막 B write/input path의 값 의존 상태가
> start-triggered capture window에 강하게 남는다. 따라서 A-E의 TVLA fail은 유효하지만,
> 그 peak를 곧바로 multiplier/MR/S7 누설로 localize하면 안 된다.

## 다음 실험

진짜 butterfly core leakage를 보려면 capture protocol을 바꿔야 한다.

1. secret `b`를 내부 preload register에 먼저 넣는다.
2. scope arm 직전에는 external `REG_B`/USB write path를 fixed 또는 dummy 값으로 scrub한다.
3. start trigger는 preload된 secret을 core로 투입하게 한다.
4. 이 상태에서 TVLA가 남으면 core arithmetic leakage다.
5. 이 상태에서 TVLA가 사라지면 지금까지의 강한 peak는 대부분 input/write path leakage다.

이 구조 없이 masking이나 delay를 바로 논하면 위험하다. 현재 dominant peak는 core masking
대상이라기보다 measurement/input interface artifact에 가깝기 때문이다.

## 보안 대책 방향

- 단기: capture 전에 secret-dependent host write가 trigger window에 남지 않도록 scrub,
  preload, trigger 분리 구조를 쓴다.
- 중기: wrapper에서 secret write path와 measured operation path를 분리하고, readback mux와
  debug fanout은 capture window 밖에서만 동작하게 한다.
- core 대책: core-only TVLA가 재현된 뒤 arithmetic masking, share-wise Montgomery, dummy
  butterflies, random scheduling을 평가한다.
- 주의: fixed delay만으로는 보안 대책이 아니다. 이번 실험의 delay는 원인 판별용이었다.
