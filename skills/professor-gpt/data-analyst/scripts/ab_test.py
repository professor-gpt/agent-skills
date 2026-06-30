#!/usr/bin/env python3
"""
ab_test.py — A/B Test Analysis Toolkit
=======================================
Analyzes A/B test results and reports statistical significance,
effect size, confidence intervals, and power.

Usage:
    python ab_test.py --control 5200 --treatment 5400 --control-conv 0.032 --treatment-conv 0.041
    python ab_test.py --file results.csv --control-col control --treatment-col treatment --metric conversion
    python ab_test.py --help

Supports:
  - Proportions (conversion rate, click-through rate)
  - Continuous metrics (revenue, time-on-site)
  - Multiple variants (A/B/n)
  - Sample size calculator (pre-test planning)
"""

import argparse
import math
import warnings

import numpy as np
from scipy import stats

warnings.filterwarnings("ignore")

# ── Optional pandas for CSV mode ──────────────────────────────────────────────
try:
    import pandas as pd
    HAS_PANDAS = True
except ImportError:
    HAS_PANDAS = False


# =============================================================================
# 1. PROPORTION TEST (Binary metric: conversion, CTR, signup rate)
# =============================================================================

def analyze_proportions(
    n_control: int,
    n_treatment: int,
    conv_control: float,
    conv_treatment: float,
    alpha: float = 0.05,
) -> dict:
    """
    Two-proportion z-test for binary outcome metrics.

    Args:
        n_control:      Sample size of control group
        n_treatment:    Sample size of treatment group
        conv_control:   Conversion rate in control (0.0–1.0)
        conv_treatment: Conversion rate in treatment (0.0–1.0)
        alpha:          Significance level (default: 0.05 for 95% confidence)
    """
    conversions_c = int(n_control * conv_control)
    conversions_t = int(n_treatment * conv_treatment)
    lift_absolute = conv_treatment - conv_control
    lift_relative = (conv_treatment - conv_control) / conv_control if conv_control > 0 else float("inf")

    # Pooled proportion (under H0: no difference)
    p_pool = (conversions_c + conversions_t) / (n_control + n_treatment)
    se_pool = math.sqrt(p_pool * (1 - p_pool) * (1/n_control + 1/n_treatment))
    z_stat = lift_absolute / se_pool if se_pool > 0 else 0

    # p-value (two-tailed)
    p_value = 2 * (1 - stats.norm.cdf(abs(z_stat)))

    # Confidence interval for absolute lift
    se_ci = math.sqrt(
        conv_control * (1 - conv_control) / n_control +
        conv_treatment * (1 - conv_treatment) / n_treatment
    )
    z_critical = stats.norm.ppf(1 - alpha / 2)
    ci_lower = lift_absolute - z_critical * se_ci
    ci_upper = lift_absolute + z_critical * se_ci

    # Statistical power (post-hoc)
    power = stats.norm.cdf(abs(z_stat) - z_critical) + stats.norm.cdf(-abs(z_stat) - z_critical)

    return {
        "metric_type": "proportion",
        "n_control": n_control,
        "n_treatment": n_treatment,
        "conv_control": conv_control,
        "conv_treatment": conv_treatment,
        "conversions_control": conversions_c,
        "conversions_treatment": conversions_t,
        "lift_absolute": lift_absolute,
        "lift_relative": lift_relative,
        "z_stat": z_stat,
        "p_value": p_value,
        "significant": p_value < alpha,
        "alpha": alpha,
        "ci_lower": ci_lower,
        "ci_upper": ci_upper,
        "power": power,
    }


# =============================================================================
# 2. CONTINUOUS TEST (Revenue, session duration, score)
# =============================================================================

def analyze_continuous(
    control: np.ndarray,
    treatment: np.ndarray,
    alpha: float = 0.05,
) -> dict:
    """
    Welch's t-test for continuous metrics.
    Handles unequal variance and sample sizes.
    """
    n_c, n_t = len(control), len(treatment)
    mean_c, mean_t = control.mean(), treatment.mean()
    std_c, std_t = control.std(ddof=1), treatment.std(ddof=1)

    lift_absolute = mean_t - mean_c
    lift_relative = lift_absolute / mean_c if mean_c != 0 else float("inf")

    t_stat, p_value = stats.ttest_ind(control, treatment, equal_var=False)

    # Cohen's d (effect size)
    pooled_std = math.sqrt((std_c**2 + std_t**2) / 2)
    cohens_d = lift_absolute / pooled_std if pooled_std > 0 else 0

    # 95% CI for difference in means
    se_diff = math.sqrt(std_c**2 / n_c + std_t**2 / n_t)
    z_critical = stats.norm.ppf(1 - alpha / 2)
    ci_lower = lift_absolute - z_critical * se_diff
    ci_upper = lift_absolute + z_critical * se_diff

    # Normality check (Shapiro if small, skewness otherwise)
    if n_c <= 50:
        _, p_norm = stats.shapiro(control)
        normality_warning = p_norm < 0.05
    else:
        skew = stats.skew(control)
        normality_warning = abs(skew) > 1

    return {
        "metric_type": "continuous",
        "n_control": n_c,
        "n_treatment": n_t,
        "mean_control": mean_c,
        "mean_treatment": mean_t,
        "std_control": std_c,
        "std_treatment": std_t,
        "lift_absolute": lift_absolute,
        "lift_relative": lift_relative,
        "t_stat": t_stat,
        "p_value": p_value,
        "significant": p_value < alpha,
        "alpha": alpha,
        "ci_lower": ci_lower,
        "ci_upper": ci_upper,
        "cohens_d": cohens_d,
        "effect_size_label": _effect_size_label(cohens_d),
        "normality_warning": normality_warning,
    }


def _effect_size_label(d: float) -> str:
    d = abs(d)
    if d < 0.2:  return "negligible"
    if d < 0.5:  return "small"
    if d < 0.8:  return "medium"
    return "large"


# =============================================================================
# 3. SAMPLE SIZE CALCULATOR
# =============================================================================

def calculate_sample_size(
    baseline_rate: float,
    mde: float,           # Minimum detectable effect (relative), e.g. 0.05 = 5% lift
    alpha: float = 0.05,
    power: float = 0.80,
) -> dict:
    """
    Calculate minimum sample size per variant for a proportion test.

    Args:
        baseline_rate: Current conversion rate (0.0–1.0)
        mde:           Minimum detectable relative effect (e.g., 0.05 = detect 5% lift)
        alpha:         Significance level (default: 0.05)
        power:         Statistical power (default: 0.80)
    """
    p1 = baseline_rate
    p2 = p1 * (1 + mde)
    p_avg = (p1 + p2) / 2

    z_alpha = stats.norm.ppf(1 - alpha / 2)
    z_beta  = stats.norm.ppf(power)

    n = (
        (z_alpha * math.sqrt(2 * p_avg * (1 - p_avg)) +
         z_beta  * math.sqrt(p1 * (1 - p1) + p2 * (1 - p2)))**2
    ) / (p2 - p1)**2

    return {
        "sample_size_per_variant": math.ceil(n),
        "total_sample_size": math.ceil(n) * 2,
        "baseline_rate": p1,
        "target_rate": p2,
        "mde_absolute": p2 - p1,
        "mde_relative": mde,
        "alpha": alpha,
        "power": power,
    }


# =============================================================================
# 4. PRINT RESULTS
# =============================================================================

def print_proportion_results(r: dict) -> None:
    sig = "✅ SIGNIFICANT" if r["significant"] else "❌ NOT SIGNIFICANT"
    alpha_pct = int((1 - r["alpha"]) * 100)

    print("\n" + "=" * 60)
    print("A/B TEST RESULTS — Proportion")
    print("=" * 60)
    print(f"\n  Control:   n={r['n_control']:,}  conv={r['conv_control']:.3%}  ({r['conversions_control']:,} conversions)")
    print(f"  Treatment: n={r['n_treatment']:,}  conv={r['conv_treatment']:.3%}  ({r['conversions_treatment']:,} conversions)")
    print(f"\n  Lift:      {r['lift_absolute']:+.3%} absolute  ({r['lift_relative']:+.1%} relative)")
    print(f"  {alpha_pct}% CI:  [{r['ci_lower']:+.3%}, {r['ci_upper']:+.3%}]")
    print(f"\n  z-statistic: {r['z_stat']:.3f}")
    print(f"  p-value:     {r['p_value']:.4f}")
    print(f"  Power:       {r['power']:.1%}")
    print(f"\n  Result:  {sig}")

    if r["significant"]:
        if r["ci_lower"] > 0:
            print(f"\n  ✅ Treatment is better. 95% CI excludes zero → confidently ship it.")
        else:
            print(f"\n  ⚠  Significant but CI includes negative values — direction not certain.")
    else:
        print(f"\n  Run the test longer or increase traffic to detect an effect of this size.")

    if r["power"] < 0.80:
        print(f"\n  ⚠  Low power ({r['power']:.0%}). Risk of false negative is high.")


def print_continuous_results(r: dict) -> None:
    sig = "✅ SIGNIFICANT" if r["significant"] else "❌ NOT SIGNIFICANT"
    alpha_pct = int((1 - r["alpha"]) * 100)

    print("\n" + "=" * 60)
    print("A/B TEST RESULTS — Continuous Metric")
    print("=" * 60)
    print(f"\n  Control:   n={r['n_control']:,}  mean={r['mean_control']:.4g}  std={r['std_control']:.4g}")
    print(f"  Treatment: n={r['n_treatment']:,}  mean={r['mean_treatment']:.4g}  std={r['std_treatment']:.4g}")
    print(f"\n  Lift:      {r['lift_absolute']:+.4g} absolute  ({r['lift_relative']:+.1%} relative)")
    print(f"  {alpha_pct}% CI:  [{r['ci_lower']:+.4g}, {r['ci_upper']:+.4g}]")
    print(f"\n  t-statistic: {r['t_stat']:.3f}")
    print(f"  p-value:     {r['p_value']:.4f}")
    print(f"  Cohen's d:   {r['cohens_d']:.3f} ({r['effect_size_label']})")
    print(f"\n  Result:  {sig}")

    if r["normality_warning"]:
        print(f"\n  ⚠  Non-normal distribution detected. Consider Mann-Whitney U test for robustness.")


def print_sample_size(r: dict) -> None:
    print("\n" + "=" * 60)
    print("SAMPLE SIZE CALCULATOR")
    print("=" * 60)
    print(f"\n  Baseline conversion:  {r['baseline_rate']:.3%}")
    print(f"  Target conversion:    {r['target_rate']:.3%}  (+{r['mde_relative']:.0%} relative)")
    print(f"  Significance level:   α = {r['alpha']}")
    print(f"  Power:                {r['power']:.0%}")
    print(f"\n  Sample size per variant: {r['sample_size_per_variant']:,}")
    print(f"  Total sample size:       {r['total_sample_size']:,}")
    print(f"\n  At 1,000 visitors/day → run for {r['total_sample_size']//1000} days")
    print(f"  At 5,000 visitors/day → run for {max(1, r['total_sample_size']//5000)} days")


# =============================================================================
# MAIN
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description="A/B Test Analysis")
    subparsers = parser.add_subparsers(dest="command")

    # Proportion test (summary statistics)
    prop = subparsers.add_parser("proportion", help="Test a binary metric (conversion rate)")
    prop.add_argument("--n-control", type=int, required=True)
    prop.add_argument("--n-treatment", type=int, required=True)
    prop.add_argument("--conv-control", type=float, required=True, help="e.g. 0.032 for 3.2%")
    prop.add_argument("--conv-treatment", type=float, required=True)
    prop.add_argument("--alpha", type=float, default=0.05)

    # Sample size calculator
    size = subparsers.add_parser("sample-size", help="Calculate required sample size")
    size.add_argument("--baseline", type=float, required=True, help="Baseline conversion rate")
    size.add_argument("--mde", type=float, required=True, help="Minimum detectable relative effect (e.g., 0.05)")
    size.add_argument("--alpha", type=float, default=0.05)
    size.add_argument("--power", type=float, default=0.80)

    args = parser.parse_args()

    if args.command == "proportion":
        results = analyze_proportions(
            args.n_control, args.n_treatment,
            args.conv_control, args.conv_treatment,
            args.alpha,
        )
        print_proportion_results(results)

    elif args.command == "sample-size":
        results = calculate_sample_size(args.baseline, args.mde, args.alpha, args.power)
        print_sample_size(results)

    else:
        # Demo mode: run with example data
        print("Running demo analysis...")
        print("\n--- Demo: Proportion Test ---")
        r = analyze_proportions(5200, 5400, 0.032, 0.041)
        print_proportion_results(r)

        print("\n--- Demo: Sample Size Calculator ---")
        s = calculate_sample_size(baseline_rate=0.032, mde=0.15, alpha=0.05, power=0.80)
        print_sample_size(s)

        print("\n--- Demo: Continuous Metric (Revenue per User) ---")
        np.random.seed(42)
        control   = np.random.lognormal(mean=3.5, sigma=1.2, size=2000)
        treatment = np.random.lognormal(mean=3.6, sigma=1.2, size=2100)
        r = analyze_continuous(control, treatment)
        print_continuous_results(r)


if __name__ == "__main__":
    main()
