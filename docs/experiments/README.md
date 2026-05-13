# Experiment Artifacts Index

세부 설명은 [../leakage_explained.md](../leakage_explained.md)에 통합했다.
이 파일은 현재 로컬에 남겨둔 대표 산출물만 나열한다.

`host/results/`의 raw capture 파일은 git에 track하지 않는다. 대신 아래 대표
run의 `tvla_plot.png`를 기준으로 결과를 추적한다. 이번 정리에서 smoke run,
invalid rail run, A-register alias 수정 전 run, 중복 gain/trigger variant는
삭제했고, 2026-05-12에는 core-start-delay 확인과 N=20000 masked/unmasked
비교 run을 추가했다.

최신 `unmasked` run은 별도 single-core bitstream이 아니라 같은 two-share bitstream에
`share0=logical value`, `share1=0`을 넣은 zero-share control이다. 따라서 같은
place-and-route/trigger 조건에서 input encoding만 비교하는 실험이다.

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
| Final masked RTL older delay check | [`20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k`](../../host/results/20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k) | [tvla_plot.png](../../host/results/20260511_210917_exp_I_masked_rtl_Aalias_tdelay2_N3k/tvla_plot.png) | `|t|=2.487`, no leakage |
| Core-start delay 0 | [`20260512_154453_exp_K_unmasked_coredelay0_N3k`](../../host/results/20260512_154453_exp_K_unmasked_coredelay0_N3k) | [tvla_plot.png](../../host/results/20260512_154453_exp_K_unmasked_coredelay0_N3k/tvla_plot.png) | `|t|=33.953 @ s22`, 42/240 fail |
| Core-start delay 4 | [`20260512_154522_exp_K_unmasked_coredelay4_N3k`](../../host/results/20260512_154522_exp_K_unmasked_coredelay4_N3k) | [tvla_plot.png](../../host/results/20260512_154522_exp_K_unmasked_coredelay4_N3k/tvla_plot.png) | `|t|=31.682 @ s30`, +8 samples |
| Core-start delay 7 | [`20260512_154544_exp_K_unmasked_coredelay7_N3k`](../../host/results/20260512_154544_exp_K_unmasked_coredelay7_N3k) | [tvla_plot.png](../../host/results/20260512_154544_exp_K_unmasked_coredelay7_N3k/tvla_plot.png) | `|t|=30.524 @ s36`, +14 samples |
| N20k unmasked | [`20260512_154612_exp_L_unmasked_N20k`](../../host/results/20260512_154612_exp_L_unmasked_N20k) | [tvla_plot.png](../../host/results/20260512_154612_exp_L_unmasked_N20k/tvla_plot.png) | `|t|=86.422 @ s24`, 33/240 fail |
| N20k masked | [`20260512_154745_exp_L_masked_N20k`](../../host/results/20260512_154745_exp_L_masked_N20k) | [tvla_plot.png](../../host/results/20260512_154745_exp_L_masked_N20k/tvla_plot.png) | `|t|=2.512 @ s43`, 0/240 fail |

## 주요 TVLA Plot

| 실험 | Plot |
|---|---|
| Final unmasked RTL N3k | <img src="../../host/results/20260511_210817_exp_I_unmasked_rtl_Aalias_N3k/tvla_plot.png" width="420"> |
| Final masked RTL N3k | <img src="../../host/results/20260511_210842_exp_I_masked_rtl_Aalias_N3k/tvla_plot.png" width="420"> |
| Core-start delay 0 | <img src="../../host/results/20260512_154453_exp_K_unmasked_coredelay0_N3k/tvla_plot.png" width="420"> |
| Core-start delay 4 | <img src="../../host/results/20260512_154522_exp_K_unmasked_coredelay4_N3k/tvla_plot.png" width="420"> |
| Core-start delay 7 | <img src="../../host/results/20260512_154544_exp_K_unmasked_coredelay7_N3k/tvla_plot.png" width="420"> |
| N20k zero-share unmasked | <img src="../../host/results/20260512_154612_exp_L_unmasked_N20k/tvla_plot.png" width="420"> |
| N20k masked | <img src="../../host/results/20260512_154745_exp_L_masked_N20k/tvla_plot.png" width="420"> |

각 폴더의 기본 구성:

- `metadata.json`: scope, bitstream md5, trigger, sample/cycle 정보
- `inputs.npz`: logical inputs, group labels, output, masked share fields
- `traces.npy`: raw ADC traces
- `tvla_t_stat.npy`: sample별 Welch t-statistic
- `tvla_plot.png`: TVLA plot
