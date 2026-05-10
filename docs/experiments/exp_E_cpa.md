# 실험 E — CPA (Correlation Power Analysis), corrected

## 목적

A-D는 "누설이 있는가? 어디에서 보이는가?"를 답한다. Exp E는 그 누설이 단순한
Hamming-weight CPA로 실제 secret 후보를 줄일 수 있는지 확인한다.

## 코드 수정

두 가지 정합성 수정을 반영했다.

1. `capture_traces.py`가 `a`를 q로 reduction한 뒤 FPGA에 주입한다. RTL add/sub는
   `a,b < q`를 전제로 하므로, 이 조건이 맞아야 butterfly 출력과 CPA 모델이 정합하다.
2. `cpa.py`의 leakage model을 mode별로 분리했다.
   - CT: `HW(b_hyp * zeta_k mod 2^32)`
   - GS: `HW(((a - b_hyp) mod q) * zeta_k mod 2^32)`

## 셋업

CPA는 TVLA와 반대로 입력을 구성한다.

- `b` 고정 (= secret, attacker가 모르는 값)
- `k` 변동 (= public, attacker가 아는 값)
- 매 trace에서 host가 임의의 k를 골라 적용

| 항목 | 값 |
|---|---|
| 알고리즘 | Kyber (q=3329), CT |
| Secret b | 0xABCDE % 3329 = 1291 |
| `a` | 0xCAFEBABE 입력, q로 reduction 후 1409 주입 |
| k 분포 | 균등 [0, 128) |
| N | 20000 traces |
| Sample window | 800 |
| Gain | 10 dB |

## 명령

```bash
python3 host/capture_traces.py \
    --bitfile bitstream/cw305_unified_butterfly2_top_v4.bit \
    --num-traces 20000 --label exp_E2_kyber_ct_cpa_a_mod_N20k \
    --mode 1 --mode2 0 --vary k --k-max 128 \
    --b-fixed 0xABCDE --samples 800 --gain-db 10 --no-program

python3 host/cpa.py host/results/<exp_E2>/ --focus-sample 18
python3 host/cpa.py host/results/<exp_E2>/ --focus-sample 21
```

데이터 위치: `host/results/20260510_201031_exp_E2_kyber_ct_cpa_a_mod_N20k/`

## 결과

### Canonical rerun

`focus_sample=18`:

```
winner: b_hyp = 3153, score = 0.0261
true secret rank: 1550 / 3329, score = 0.0049
```

`focus_sample=21`:

```
winner: b_hyp = 1201, score = 0.0222
true secret rank: 1829 / 3329, score = 0.0046
```

random guess의 평균 rank는 약 1665이므로, corrected canonical capture에서는 naive HW CPA가
secret 후보 공간을 줄이지 못했다.

### Legacy result 해석 변경

초기 문서의 rank 120/3329 결과는 `a=0xCAFEBABE`가 q로 줄지 않고 RTL에 들어간
legacy capture에서 나온 값이다.

```
legacy v3: true rank 120 / 3329
legacy v4: true rank 509 / 3329
```

이 결과는 "비정규 입력을 넣은 상태에서도 측정값과 어떤 모델이 상관된다"는 참고 기록으로
남길 수 있지만, canonical butterfly 조건의 공격 효율로 주장하면 안 된다.

## 결론

| 질문 | 답 |
|---|---|
| TVLA 누설이 실제로 존재하는가? | 예. A-C에서 강하게 재현됨 |
| canonical input에서 naive HW CPA로 top-1 복구 가능한가? | 아니오 |
| canonical input에서 search space가 줄었는가? | 아니오. rank가 random 수준 |
| 더 강한 공격 가능성? | 미확인. template/profiling, 다중 sample, 다중 중간값 모델 필요 |

따라서 corrected 결론은 **TVLA fail은 확실하지만, 단일-sample naive HW CPA의 exploitability는
입증되지 않았다**이다.

## 파일

```
host/results/20260510_201031_exp_E2_kyber_ct_cpa_a_mod_N20k/
├── traces.npy
├── inputs.npz
├── metadata.json
├── cpa_scores.npy
├── cpa_winning_corr.npy
└── cpa_plot.png
```
