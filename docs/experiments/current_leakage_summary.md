# 현재까지의 목표, 실험, 결론 요약

이 문서는 지금까지의 대화를 한 번에 다시 읽을 수 있도록 정리한 요약이다.
핵심 질문은 단순했다.

> 새 unified butterfly에서 보이는 TVLA 누설이 진짜 butterfly core 계산 때문인가,
> 아니면 CW305/ChipWhisperer 측정 구조에서 입력을 쓰는 과정 때문인가?

## 1. 처음 목표

처음 목표는 두 갈래였다.

첫째, 실험을 다른 컴퓨터와 다른 ChipWhisperer scope에서도 재현 가능하게 만드는 것.
현재 장비는 CW305 + Husky-Plus였지만, CW-Lite/Pro에서는 ADC MHz와
samples-per-cycle이 달라지므로 sample 번호를 그대로 비교하면 안 된다. 그래서 capture
code와 문서에서 target cycle 기준으로 해석하도록 정리했다.

둘째, 강한 TVLA peak의 진짜 위치를 찾는 것. 기존 trace에서는 peak가 sample 20대에
나왔고, Husky-Plus 기준 2 samples/cycle이므로 이것은 대략 S7/post-result window와
겹쳤다. 그래서 처음에는 final `out1/out2` register 또는 그 fanout이 주 누설점이라는
가설이 있었다.

하지만 sample 위치만으로는 원인을 확정할 수 없다. PC가 USB로 CW305의 `REG_B`에 값을
쓴 직후 scope를 arm하고 start를 걸기 때문에, 입력 write path의 전기적 상태도 같은
capture window에 남을 수 있다.

## 2. 보드와 ChipWhisperer에서 값이 흐르는 경로

전체 흐름은 다음과 같다.

```text
PC Python host
  -> ChipWhisperer API
  -> CW305 USB register write
  -> FPGA wrapper shadow register
  -> start write
  -> butterfly core input register
  -> unified_butterfly2_top
  -> unified_bufferfly2 core
  -> out1/out2 wire
  -> wrapper output register
  -> host readback
```

좀 더 구체적으로는:

```text
REG_A write -> a_shadow
REG_B write -> b_shadow
REG_K write -> k_shadow
REG_CTRL    -> mode/mode2/preload/trigger control

start write:
  a_shadow -> a_core
  b_shadow 또는 b_preload -> b_core
  k_shadow -> k_core

butterfly:
  b_core와 ROM zeta가 들어감
  b * zeta multiplier
  Montgomery reduction
  S7 final add/sub
  out1_wire/out2_wire

wrapper:
  out1_wire/out2_wire -> out1_reg/out2_reg
  host가 REG_OUT1/REG_OUT2로 readback
```

ChipWhisperer Husky-Plus는 CW305의 전원 SMA 출력과 `tio_trigger`를 보고 trace를 잡는다.
CW305는 `trigger_reg`를 `tio_trigger`로 내보낸다. default delay 0에서는 start와
정렬되고, Exp G에서는 trigger delay를 바꿔 stage alignment도 확인했다.

## 3. 기존 trace 재분석

기존 20k trace를 다시 요약했을 때 Kyber/Dilithium CT/GS 모두 강한 TVLA fail이 있었다.

| 데이터 | 대표 peak |
|---|---:|
| Kyber CT | `|t| ~= 90 @ sample 21` |
| Kyber GS | `|t| ~= 88 @ sample 24` |
| Dilithium CT/GS | `|t| ~= 94-98` |

sample 20대는 S7/post-result window와 겹친다. 그래서 초기 가설은:

> `b * zeta` 값이 Montgomery reduction을 지나 final `out1/out2`와 post-result fanout에
> 도달한 직후 강하게 샌다.

였다. 이후 실험들은 이 가설을 검증하기 위해 진행했다.

## 4. Exp F: normal capture peak에 input write path가 섞였는지 검증

Exp F에서는 여러 isolation bitstream/host policy를 만들어서 기존 peak를 분해했다.

주요 결과:

| 실험 | 무엇을 바꿨나 | 결과 |
|---|---|---:|
| S7 correction 제거 | final 조건문 제거 | peak 유지 |
| dummy output | `out1/out2`를 secret-independent로 교체 | peak 유지 |
| core `.b=0`, `b_core=0` | core 계산에서 secret 제거 | peak 유지 |
| actual B write constant | group label은 유지, FPGA에 쓰는 `REG_B`만 fixed | peak 사라짐 |
| F11 random-then-scrub | random `REG_B` write 후 arm 직전 fixed `REG_B`로 scrub | peak 사라짐 |

F11의 흐름은 다음과 같다.

```text
logical random/fixed b를 REG_B에 먼저 씀
-> scope arm 직전 REG_B를 fixed 값으로 다시 씀
-> start
-> core가 보는 b_core도 fixed
-> TVLA no leak
```

따라서 F11이 보인 것은:

> normal capture의 강한 peak에는 마지막 `REG_B` write/input path 상태가 크게 섞여 있다.

하지만 F11만으로 "butterfly core는 안전하다"고 말할 수는 없다. F11에서는 마지막에
`REG_B`를 fixed로 scrub했기 때문에, core 입력 `b_core`도 fixed가 된다. 즉 core가
random/fixed secret을 계산하지 않는다.

## 5. Exp G: 진짜 core-only preload/scrub 실험

F11의 한계를 없애기 위해 Exp G에서는 wrapper에 내부 `B_PRELOAD` register를 추가했다.
목표는:

> 외부 `REG_B` start 값은 fixed로 고정하되, butterfly core가 실제로 보는 `b_core`만
> fixed/random으로 바꿔보자.

이를 위해 wrapper에 다음 mux를 넣었다.

```text
normal:
  b_core <= b_shadow

Exp G:
  b_core <= b_preload
```

Exp G의 core-only 흐름은:

```text
logical random/fixed b를 B_PRELOAD에 미리 저장
-> REG_B는 fixed 값으로 scrub
-> scope arm
-> start
-> wrapper가 b_shadow가 아니라 b_preload를 b_core로 선택
-> butterfly core가 random/fixed b를 계산
-> TVLA 측정
```

실험 전에 health gate도 통과시켰다.

| 확인 | 결과 |
|---|---:|
| `REG_ID` | `0xc4` |
| route mode `REG_CTRL` | write/read 정상 |
| `B_PRELOAD` | 원하는 preload 값 readback |
| `REG_B` | scrub fixed 값 readback |

여기서 중요한 host-side 수정도 있었다. ChipWhisperer CW305 driver는 FPGA가 이미
programmed이면 새 `bsfile`을 줘도 기본적으로 재프로그램하지 않는다. 그래서
`capture_traces.py`에서 `--no-program`이 아닐 때 `force=True`로 실제 bitstream을 항상
올리게 고쳤다.

## 6. Exp G 결과

공통 조건: CW305 + Husky-Plus, target clock 약 95.999 MHz, 2 samples/cycle,
Kyber CT, `k=16`, N=3000.

| 실험 | 실제 start 조건 | 결과 |
|---|---|---:|
| Positive normal | `REG_B`와 `b_core` 모두 fixed/random | `|t|=30.749 @ s21` |
| Constant scrub | `REG_B`도 fixed, `b_core`도 fixed | `|t|=2.461`, no leak |
| Core-only preload delay 0 | `REG_B` fixed, `b_preload`/`b_core` fixed/random | `|t|=29.788 @ s23` |
| Core-only preload delay 2 | 같은 조건, trigger 2 cycle delay | `|t|=33.662 @ s16` |
| Force core zero | `b_preload`는 fixed/random, `b_core=0` | `|t|=3.407`, no leak |

force-zero control이 가장 중요하다.

```text
B_PRELOAD는 계속 random/fixed로 바뀜
하지만 start 때 b_core는 0으로 강제
-> TVLA no leak
```

따라서 "그냥 preload register에 random 값이 저장돼서 샌 것"이라고 보기 어렵다.
preload traffic은 남아 있어도, 그 값이 `b_core`로 들어가 계산되지 않으면 누출이
사라졌기 때문이다.

## 7. 최종 결론

정확한 결론은 두 단계다.

1. **Exp F/F11 결론**:
   normal capture의 강한 peak에는 `REG_B` write/input path 영향이 크게 섞여 있다.
   따라서 sample 위치만 보고 곧바로 final `out1/out2` register가 주 원인이라고 말하면
   안 된다.

2. **Exp G 결론**:
   external `REG_B` start 값을 fixed로 scrub해도, 내부 preload를 통해 `b_core`가
   fixed/random으로 butterfly 계산에 들어가면 강한 TVLA peak가 다시 생긴다.
   따라서 새 unified butterfly core의 값 의존 누출은 실제로 존재한다.

한 문장으로 쓰면:

> F11은 "입력 write path가 normal capture peak에 크게 섞였다"를 보였고, Exp G는
> "그 write path를 제거해도 butterfly core 계산 자체에서 누출이 난다"를 보였다.

다만 아직 확정하지 않은 것도 있다. 지금 결과는 "core 연산 경로에서 누출이 난다"는
것을 보여주지만, core 안의 딱 한 register만 범인이라고 단정하지는 않는다. 현재 가장
정합한 위치 해석은:

```text
b_core
-> b * zeta multiplier
-> Montgomery reduction
-> S7 out1/out2
-> post-result routing/fanout
```

이 흐름 중 `b * zeta`가 Montgomery 후반과 S7/post-result window에 도달한 직후의
값 의존 switching이 강하게 보인다는 것이다.

## 8. 앞으로의 의미

masking은 의미가 있다. Exp G로 core-only 누출이 재현됐기 때문이다. 단, masking을
평가할 때는 normal capture가 아니라 preload/scrub 구조를 기준으로 해야 한다. 그래야
host write path artifact와 core leakage를 분리해서 볼 수 있다.

가장 현실적인 다음 단계:

- `b`를 arithmetic share로 나눠 multiplier/Montgomery를 share-wise로 처리.
- `out1/out2`가 unmasked로 재결합되는 시점을 capture window 밖으로 미루거나 최소화.
- random delay나 dummy butterfly는 보조 hiding으로만 사용.
- countermeasure 적용 전후를 Exp G와 같은 preload/scrub 조건에서 다시 TVLA로 비교.
