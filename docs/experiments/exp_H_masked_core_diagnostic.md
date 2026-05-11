# 실험 H — core preload 경로에 2-share masking 적용

## 목적

Exp G에서 external `REG_B` start 값을 fixed로 scrub해도, 내부 preload로 `b_core`가
fixed/random으로 바뀌면 강한 TVLA peak가 남는 것을 확인했다. Exp H의 목적은 그
core-only 누설 경로에 1차 masking을 적용했을 때 TVLA가 실제로 낮아지는지 보는 것이다.

## masking 설계

Kyber/Dilithium butterfly에서 zeta는 public이고, CT 경로의 핵심 누설 후보는
`b * zeta`가 multiplier/Montgomery/S7 window로 전파되는 과정이다. public zeta 곱은
선형이므로 logical secret `b`를 다음처럼 나눌 수 있다.

```text
b = b0 + b1 mod q
```

여기서 `b0`는 trace마다 새로 뽑은 random mask share이고,
`b1 = b - b0 mod q`이다. fixed/random TVLA label은 logical `b`에 대해 그대로 유지한다.
하지만 core에는 logical `b` 자체를 넣지 않고 `b0` 또는 `b1` 한 share만 넣는다.

```text
REG_B start 값     = fixed scrub value
B_PRELOAD          = b0 또는 b1
start 시 b_core    = B_PRELOAD
butterfly core 입력 = random share
```

이 실험은 **진단용 first-order masking 실험**이다. 완성형 masked NTT 구현은 아니다.
완성형 countermeasure에서는 두 share를 모두 계산하고, `out1/out2`도 unmasked로
재결합하지 않은 채 capture window 밖까지 share-wise로 유지해야 한다.

그럼에도 이 실험은 정합하다. 각 share 단독 분포는 logical fixed/random `b`와 독립이므로,
core 누설이 share 값에만 의존한다면 1차 TVLA는 사라져야 한다.

## 구현

`host/capture_traces.py`에 preload policy를 추가했다.

- `--b-preload-policy masked-share0`
  - `b_mask_share0 = random in [0,q)`
  - `b_mask_share1 = b - b_mask_share0 mod q`
  - `B_PRELOAD = b_mask_share0`
- `--b-preload-policy masked-share1`
  - 같은 share 생성
  - `B_PRELOAD = b_mask_share1`

`inputs.npz`에는 다음 필드가 저장된다.

- `b`: logical TVLA grouping value
- `b_effective_start`: external `REG_B` start value
- `b_preload_write`: 실제 `B_PRELOAD`에 쓴 값
- `b_core_start`: wrapper가 core에 넣은 값
- `b_mask_share0`, `b_mask_share1`

sanity condition:

```text
(b_mask_share0 + b_mask_share1) mod q == b
```

## 재현 명령

Unmasked positive:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_H_unmasked_core_tdelay0_gain0_N3k \
    --num-traces 3000 \
    --sample-cycles 120 \
    --trigger-mode internal \
    --gain-db 0 \
    --mode 1 --mode2 0 --k 16 \
    --seed 0xC0FFEE \
    --b-fixed 0x12345678 \
    --b-load-policy constant \
    --b-scrub-value 0x12345678 \
    --b-preload-policy logical \
    --use-b-preload
```

Masked share 0:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_H_masked_share0_tdelay0_gain0_N3k \
    --num-traces 3000 \
    --sample-cycles 120 \
    --trigger-mode internal \
    --gain-db 0 \
    --mode 1 --mode2 0 --k 16 \
    --seed 0xC0FFEE \
    --b-fixed 0x12345678 \
    --b-load-policy constant \
    --b-scrub-value 0x12345678 \
    --b-preload-policy masked-share0 \
    --use-b-preload
```

Masked share 1:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_H_masked_share1_tdelay2_gain0_N3k \
    --num-traces 3000 \
    --sample-cycles 120 \
    --trigger-mode internal \
    --gain-db 0 \
    --mode 1 --mode2 0 --k 16 \
    --seed 0xC0FFEE \
    --b-fixed 0x12345678 \
    --b-load-policy constant \
    --b-scrub-value 0x12345678 \
    --b-preload-policy masked-share1 \
    --use-b-preload \
    --trigger-delay-cycles 2
```

분석:

```bash
python3 host/tvla.py host/results/<timestamp>_<label>
```

## 2026-05-11 결과

공통 조건: CW305 + Husky-Plus, measured target clock about 95.999 MHz,
2 samples/target cycle, Kyber CT (`mode=1`, `mode2=0`, `k=16`), N=3000.

| 실험 | Result dir | core 입력 | peak | 판정 |
|---|---|---|---:|---|
| Unmasked core | `20260511_204150_exp_H_unmasked_core_tdelay0_gain0_N3k` | logical `b` | `|t|=31.186 @ s23` | leakage |
| Masked share0 | `20260511_204220_exp_H_masked_share0_tdelay0_gain0_N3k` | random share `b0` | `|t|=3.153` | no first-order leakage |
| Masked share1 | `20260511_204432_exp_H_masked_share1_tdelay2_gain0_N3k` | random share `b1` | `|t|=1.537` | no first-order leakage |

무효로 제외한 run:

- `20260511_204246_exp_H_masked_share1_tdelay0_gain0_N3k`
- `20260511_204340_exp_H_masked_share1_tdelay0_gain0_retry_N3k`
- `20260511_204602_exp_H_unmasked_core_tdelay2_gain0_N3k`
- `20260511_204627_exp_H_masked_share0_tdelay2_gain0_N3k`

위 run들은 trace가 `-0.5` rail에 닿아 TVLA 판정에서 제외했다.

## Sanity check

유효 masked runs에서 확인한 조건:

| 실험 | `b_effective_start` unique | `b_core_start` unique | share sum |
|---|---:|---:|---|
| Masked share0 | 1 | 1937 | OK |
| Masked share1 | 1 | 1998 | OK |

즉 external `REG_B` start 값은 fixed로 유지됐고, core가 본 값은 logical `b`가 아니라
random share였다. 또한 `(b0 + b1) mod q == b`가 모든 trace에서 성립했다.

## 결론

Exp H는 Exp G에서 확인된 core-only leakage에 first-order masking을 적용하면 TVLA가
임계값 아래로 떨어질 수 있음을 보였다.

정확히 말하면:

> unmasked logical `b`를 `b_core`로 넣으면 `|t|=31.186`의 강한 누설이 난다.
> 같은 preload/scrub 조건에서 `b_core`를 random share로 바꾸면 `|t|=3.153` 또는
> `1.537`로 내려간다.

따라서 masking 방향은 의미가 있다. 다만 이 결과를 "완성형 masked butterfly 구현이
안전하다"로 해석하면 안 된다. 아직은 diagnostic이다. 다음 단계는 두 share를 모두
하드웨어에서 계산하고, unmasked recombination을 capture window 밖으로 미루거나
아예 share-wise output register로 유지하는 RTL을 구현한 뒤 같은 TVLA를 반복하는 것이다.
