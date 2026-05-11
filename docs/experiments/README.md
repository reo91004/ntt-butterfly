# Experiment Artifacts Index

세부 설명은 [../leakage_explained.md](../leakage_explained.md)에 통합했다.
이 파일은 현재 로컬에 남겨둔 대표 산출물만 나열한다.

`host/results/`의 raw capture 파일은 git에 track하지 않는다. 대신 아래 12개 대표
run의 `tvla_plot.png`만 커밋에 포함했다. 이번 정리에서 smoke run, invalid rail run,
A-register alias 수정 전 run, 중복 gain/trigger variant는 삭제했고, 논리 흐름을
증명하는 대표 12개만 남겼다.

## 남긴 산출물

| 단계 | 폴더 | TVLA plot | 핵심 결과 |
|---|---|---|---|
| Baseline Kyber CT | [`20260510_200546_exp_A2_kyber_ct_a_mod_N20k`](../../host/results/20260510_200546_exp_A2_kyber_ct_a_mod_N20k) | [tvla_plot.png](../../host/results/20260510_200546_exp_A2_kyber_ct_a_mod_N20k/tvla_plot.png) | `|t|=90.321 @ s21` |
| Baseline Kyber GS | [`20260510_200722_exp_B2_kyber_gs_a_mod_N20k`](../../host/results/20260510_200722_exp_B2_kyber_gs_a_mod_N20k) | [tvla_plot.png](../../host/results/20260510_200722_exp_B2_kyber_gs_a_mod_N20k/tvla_plot.png) | `|t|=88.009 @ s24` |
| Baseline Dilithium CT | [`20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k`](../../host/results/20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k) | [tvla_plot.png](../../host/results/20260510_201256_exp_C1b_dil_ct_a_mod_k1_N20k/tvla_plot.png) | `|t|=93.866 @ s24` |
| F11 normal positive | [`20260511_175513_exp_F11_positive_control_normal_N3k`](../../host/results/20260511_175513_exp_F11_positive_control_normal_N3k) | [tvla_plot.png](../../host/results/20260511_175513_exp_F11_positive_control_normal_N3k/tvla_plot.png) | `|t|=34.841 @ s21` |
| F11 B scrub | [`20260511_175422_exp_F11_random_b_then_fixed_b_scrub_repro_N3k`](../../host/results/20260511_175422_exp_F11_random_b_then_fixed_b_scrub_repro_N3k) | [tvla_plot.png](../../host/results/20260511_175422_exp_F11_random_b_then_fixed_b_scrub_repro_N3k/tvla_plot.png) | `|t|=2.957`, no leakage |
| Core-only preload | [`20260511_194055_exp_F12b_preload_core_tdelay0_gain0_N3k`](../../host/results/20260511_194055_exp_F12b_preload_core_tdelay0_gain0_N3k) | [tvla_plot.png](../../host/results/20260511_194055_exp_F12b_preload_core_tdelay0_gain0_N3k/tvla_plot.png) | `|t|=29.788 @ s23` |
| Force core zero | [`20260511_194134_exp_F12b_preload_force_core_zero_gain0_N3k`](../../host/results/20260511_194134_exp_F12b_preload_force_core_zero_gain0_N3k) | [tvla_plot.png](../../host/results/20260511_194134_exp_F12b_preload_force_core_zero_gain0_N3k/tvla_plot.png) | `|t|=3.407`, no leakage |
| Diagnostic unmasked | [`20260511_204150_exp_H_unmasked_core_tdelay0_gain0_N3k`](../../host/results/20260511_204150_exp_H_unmasked_core_tdelay0_gain0_N3k) | [tvla_plot.png](../../host/results/20260511_204150_exp_H_unmasked_core_tdelay0_gain0_N3k/tvla_plot.png) | `|t|=31.186 @ s23` |
| Diagnostic masked share | [`20260511_204220_exp_H_masked_share0_tdelay0_gain0_N3k`](../../host/results/20260511_204220_exp_H_masked_share0_tdelay0_gain0_N3k) | [tvla_plot.png](../../host/results/20260511_204220_exp_H_masked_share0_tdelay0_gain0_N3k/tvla_plot.png) | `|t|=3.153`, no leakage |
| Final unmasked RTL | [`20260511_210817_exp_I_unmasked_rtl_Aalias_N3k`](../../host/results/20260511_210817_exp_I_unmasked_rtl_Aalias_N3k) | [tvla_plot.png](../../host/results/20260511_210817_exp_I_unmasked_rtl_Aalias_N3k/tvla_plot.png) | `|t|=32.477 @ s21` |
| Final masked RTL | [`20260511_210842_exp_I_masked_rtl_Aalias_N3k`](../../host/results/20260511_210842_exp_I_masked_rtl_Aalias_N3k) | [tvla_plot.png](../../host/results/20260511_210842_exp_I_masked_rtl_Aalias_N3k/tvla_plot.png) | `|t|=3.035`, no leakage |
| Final masked RTL delay 2 | [`20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k`](../../host/results/20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k) | [tvla_plot.png](../../host/results/20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k/tvla_plot.png) | `|t|=2.487`, no leakage |

각 폴더의 기본 구성:

- `metadata.json`: scope, bitstream md5, trigger, sample/cycle 정보
- `inputs.npz`: logical inputs, group labels, output, masked share fields
- `traces.npy`: raw ADC traces
- `tvla_t_stat.npy`: sample별 Welch t-statistic
- `tvla_plot.png`: TVLA plot
