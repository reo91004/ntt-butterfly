# 실험 G — preload/scrub core-only butterfly 누설 분리

## 목적

Exp F11은 현재 capture protocol의 강한 peak가 마지막 `REG_B` write/input path에
크게 지배된다는 것을 보였다. 하지만 그것만으로 butterfly core가 안전하다는 뜻은
아니다. 이 실험은 외부 `REG_B`/USB write path를 fixed 값으로 scrub한 뒤, 내부
preload register에서만 `b_core`를 fixed/random으로 바꿔 **새 unified butterfly core
자체가 1차 TVLA에서 새는지** 확인한다.

## RTL/host 설계

wrapper에 `B_PRELOAD` register를 추가했다.

- `REG_B` write는 평소에는 기존 `b_shadow`로 간다.
- `REG_CTRL[4]=1`일 때만 같은 `REG_B` write가 `b_preload`로 route된다.
- start 시 `REG_CTRL[2]=1`이면 core는 `b_shadow`가 아니라 `b_preload`를 `b_core`로
  load한다.
- `REG_CTRL[3]=1`은 negative control용으로 `b_core=0`을 강제한다.
- `REG_CTRL[7:5]`는 internal trigger delay, 0-7 target cycles.

중요한 host-side 수정: ChipWhisperer CW305 driver는 FPGA가 이미 programmed이면
`bsfile`을 줘도 기본적으로 재프로그램하지 않는다. 그래서 `host/capture_traces.py`는
`--no-program`이 아닐 때 `force=True`로 bitstream을 항상 다시 올리게 했다. 이 수정
없이는 새 bitstream 실험이 이전 bitstream으로 실행될 수 있다.

재빌드 명령:

```bash
vivado-on
vivado -mode batch -source scripts/rebuild_unified_butterfly2_bitstream.tcl
```

## Health gate

capture 전에 다음 readback을 통과해야 한다.

| 항목 | 확인값 |
|---|---:|
| `REG_ID` | `0xc4` |
| route mode `REG_CTRL` | write/read `0x55` |
| idle preload mode `REG_CTRL` | write/read `0x45` |
| `B_PRELOAD` after routed `REG_B=0xaabbccdd` | `0xaabbccdd` |
| `REG_B` after scrub `REG_B=0x11223344` | `0x11223344` |

이 gate는 2026-05-11 실험에서 통과했다.

## 재현 명령

Positive control:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_F12b_positive_control_normal_gain5_N3k \
    --num-traces 3000 \
    --sample-cycles 120 \
    --trigger-mode internal \
    --gain-db 5 \
    --mode 1 --mode2 0 --k 16 \
    --seed 0xC0FFEE \
    --b-fixed 0x12345678 \
    --b-load-policy normal
```

Core-only preload/scrub:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_F12b_preload_core_tdelay0_gain0_N3k \
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

Negative control:

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --label exp_F12b_preload_force_core_zero_gain0_N3k \
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
    --use-b-preload \
    --force-core-b-zero
```

분석:

```bash
python3 host/tvla.py host/results/<timestamp>_<label>
```

## 2026-05-11 결과

공통 조건: CW305 + Husky-Plus, measured target clock about 95.999 MHz,
2 samples/target cycle, Kyber CT (`mode=1`, `mode2=0`, `k=16`), N=3000.

| 실험 | Result dir | 실제 start 조건 | peak | 판정 |
|---|---|---|---:|---|
| Positive normal | `20260511_193738_exp_F12b_positive_control_normal_gain5_N3k` | `REG_B`/`b_core` fixed/random | `|t|=30.749 @ s21` | 측정계 정상 |
| Constant scrub | `20260511_193805_exp_F12b_regb_constant_scrub_gain5_N3k` | `REG_B`/`b_core` fixed | `|t|=2.461` | no leakage |
| Preload core, delay 0 | `20260511_194055_exp_F12b_preload_core_tdelay0_gain0_N3k` | `REG_B` fixed, `b_preload`/`b_core` fixed/random | `|t|=29.788 @ s23` | leakage |
| Preload core, delay 2 | `20260511_193922_exp_F12b_preload_core_tdelay2_gain5_N3k` | `REG_B` fixed, `b_preload`/`b_core` fixed/random | `|t|=33.662 @ s16` | leakage |
| Force core zero, gain 0 | `20260511_194134_exp_F12b_preload_force_core_zero_gain0_N3k` | `b_preload` fixed/random, `b_core=0` | `|t|=3.407` | no leakage |
| Force core zero, gain 5 | `20260511_193857_exp_F12b_preload_force_core_zero_gain5_N3k` | `b_preload` fixed/random, `b_core=0` | `|t|=2.813` | no leakage |

무효로 제외한 run: `20260511_193830_exp_F12b_preload_core_tdelay0_gain5_N3k`는
`trace min=-0.5`로 ADC rail에 닿았다. 같은 조건을 gain 0에서 다시 캡처한 결과가
위의 valid delay 0 결과다.

## Sanity check

핵심 valid run의 `inputs.npz` 검산:

| 실험 | `b_effective_start` unique | `b_preload_write` unique | `b_core_start` unique | `out1/out2` unique |
|---|---:|---:|---:|---:|
| Positive normal | 1208 | 1 | 1208 | 1208 / 1208 |
| Constant scrub | 1 | 1 | 1 | 1 / 1 |
| Preload core delay 0 | 1 | 1208 | 1208 | 1208 / 1208 |
| Preload core delay 2 | 1 | 1208 | 1208 | 1208 / 1208 |
| Force core zero | 1 | 1208 | 1 | 1 / 1 |

따라서 preload core run은 논리적으로 원하는 조건을 만족한다. 외부 `REG_B` start 값은
고정이고, core가 실제로 보는 `b_core`와 결과만 fixed/random으로 바뀐다.

## 결론

새 unified butterfly core는 preload/scrub으로 external `REG_B` write path를 고정해도
1차 TVLA에서 강하게 샌다. 즉 Exp F11의 결론은 "normal capture의 dominant peak에는
`REG_B` write/input path가 섞여 있다"였고, Exp G의 추가 결론은 **그 path를 제거해도
butterfly core/Montgomery/S7 이후 값 의존 누설이 남는다**이다.

위치 해석은 보수적으로 해야 한다. delay 0의 peak `s23`과 delay 2의 peak `s16`은
trigger 이동량 2 cycles = 4 samples를 보정하면 둘 다 원래 timeline의 `s20-s23`
근처다. 이는 `b_core` load 순간 자체보다 `b*zeta`가 Montgomery 후반과 S7/post-result
window로 전파된 직후에 더 잘 맞는다.

따라서 현재 가장 정합한 표현은:

> 주 누설은 secret-dependent `b`가 butterfly core로 들어간 뒤, multiplier/Montgomery
> pipeline을 지나 S7/post-result window에 도달한 값 의존 switching이다. 단순한
> host `REG_B` write만은 아니며, 단순한 preload register 저장만도 아니다.
