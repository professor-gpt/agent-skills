#!/usr/bin/env python3
"""
eda.py — Exploratory Data Analysis Toolkit
==========================================
Run a full EDA on any CSV/Excel/Parquet file with one command.

Usage:
    python eda.py data.csv
    python eda.py data.csv --target revenue
    python eda.py data.csv --output eda-report.html
    python eda.py data.csv --sample 10000  # sample large files

Output: Console summary + optional HTML report
"""

import sys
import argparse
import warnings
from pathlib import Path

import numpy as np
import pandas as pd

warnings.filterwarnings("ignore")

# ── Optional: richer HTML report ─────────────────────────────────────────────
try:
    import ydata_profiling as yp
    HAS_PROFILING = True
except ImportError:
    HAS_PROFILING = False


# =============================================================================
# 1. LOAD DATA
# =============================================================================

def load_data(path: str, sample: int | None = None) -> pd.DataFrame:
    """Load CSV, Excel, Parquet, or JSON."""
    p = Path(path)
    loaders = {
        ".csv":     pd.read_csv,
        ".tsv":     lambda f: pd.read_csv(f, sep="\t"),
        ".xlsx":    pd.read_excel,
        ".xls":     pd.read_excel,
        ".parquet": pd.read_parquet,
        ".json":    pd.read_json,
        ".jsonl":   lambda f: pd.read_json(f, lines=True),
    }
    loader = loaders.get(p.suffix.lower())
    if not loader:
        raise ValueError(f"Unsupported file type: {p.suffix}")

    print(f"\nLoading {path}...")
    df = loader(path)
    print(f"  Shape: {df.shape[0]:,} rows × {df.shape[1]} columns")

    if sample and len(df) > sample:
        df = df.sample(sample, random_state=42)
        print(f"  Sampled to {sample:,} rows")

    return df


# =============================================================================
# 2. OVERVIEW
# =============================================================================

def print_overview(df: pd.DataFrame) -> None:
    print("\n" + "=" * 60)
    print("DATASET OVERVIEW")
    print("=" * 60)
    print(f"  Rows:    {len(df):,}")
    print(f"  Columns: {df.shape[1]}")
    print(f"  Memory:  {df.memory_usage(deep=True).sum() / 1024**2:.1f} MB")
    print(f"  Duplicates: {df.duplicated().sum():,} ({df.duplicated().mean():.1%})")


# =============================================================================
# 3. COLUMN TYPES
# =============================================================================

def analyze_types(df: pd.DataFrame) -> dict:
    """Classify columns by inferred type."""
    numeric   = df.select_dtypes(include=np.number).columns.tolist()
    boolean   = df.select_dtypes(include=bool).columns.tolist()
    datetime  = df.select_dtypes(include="datetime").columns.tolist()
    text      = df.select_dtypes(include="object").columns.tolist()
    # Try to identify date-looking string columns
    potential_dates = [
        c for c in text
        if any(kw in c.lower() for kw in ["date", "time", "at", "created", "updated"])
    ]

    print("\n" + "=" * 60)
    print("COLUMN TYPES")
    print("=" * 60)
    print(f"  Numeric ({len(numeric)}):  {numeric}")
    print(f"  Boolean ({len(boolean)}):  {boolean}")
    print(f"  Datetime ({len(datetime)}): {datetime}")
    print(f"  Text/Object ({len(text)}):  {text}")
    if potential_dates:
        print(f"  ⚠  Possible dates stored as strings: {potential_dates}")

    return {"numeric": numeric, "boolean": boolean, "datetime": datetime, "text": text}


# =============================================================================
# 4. MISSING VALUES
# =============================================================================

def analyze_missing(df: pd.DataFrame) -> pd.DataFrame:
    missing = df.isnull().sum()
    pct = (missing / len(df) * 100).round(2)
    result = pd.DataFrame({"count": missing, "pct": pct})
    result = result[result["count"] > 0].sort_values("pct", ascending=False)

    print("\n" + "=" * 60)
    print("MISSING VALUES")
    print("=" * 60)
    if result.empty:
        print("  ✅ No missing values found!")
    else:
        print(f"  {len(result)} columns have missing values:\n")
        for col, row in result.iterrows():
            bar = "█" * int(row["pct"] / 5) + "░" * (20 - int(row["pct"] / 5))
            severity = "🔴" if row["pct"] > 50 else "🟡" if row["pct"] > 10 else "🟢"
            print(f"  {severity} {col:<30} {bar} {row['count']:>8,} ({row['pct']:>5.1f}%)")

    return result


# =============================================================================
# 5. NUMERIC SUMMARY
# =============================================================================

def analyze_numeric(df: pd.DataFrame, columns: list[str]) -> None:
    if not columns:
        return

    print("\n" + "=" * 60)
    print("NUMERIC COLUMN SUMMARY")
    print("=" * 60)

    stats = df[columns].agg([
        "count", "mean", "std", "min",
        lambda x: x.quantile(0.25),
        "median",
        lambda x: x.quantile(0.75),
        "max",
    ]).T
    stats.columns = ["count", "mean", "std", "min", "q25", "median", "q75", "max"]
    stats["skew"]     = df[columns].skew()
    stats["outliers"] = [
        int(((df[c] < df[c].quantile(0.25) - 1.5*(df[c].quantile(0.75)-df[c].quantile(0.25))) |
             (df[c] > df[c].quantile(0.75) + 1.5*(df[c].quantile(0.75)-df[c].quantile(0.25)))).sum())
        for c in columns
    ]

    for col, row in stats.iterrows():
        print(f"\n  {col}")
        print(f"    Mean ± Std: {row['mean']:.4g} ± {row['std']:.4g}")
        print(f"    Range:      [{row['min']:.4g}, {row['max']:.4g}]")
        print(f"    Quartiles:  Q25={row['q25']:.4g}  Med={row['median']:.4g}  Q75={row['q75']:.4g}")
        print(f"    Skewness:   {row['skew']:.3f}", end="")
        if abs(row["skew"]) > 1:
            print("  ⚠  (|skew| > 1 — consider log transform)", end="")
        print()
        print(f"    Outliers:   {row['outliers']:,} rows ({100*row['outliers']/len(df):.1f}%)")


# =============================================================================
# 6. CATEGORICAL SUMMARY
# =============================================================================

def analyze_categorical(df: pd.DataFrame, columns: list[str], top_n: int = 10) -> None:
    if not columns:
        return

    print("\n" + "=" * 60)
    print("CATEGORICAL COLUMN SUMMARY")
    print("=" * 60)

    for col in columns:
        n_unique = df[col].nunique()
        top = df[col].value_counts().head(top_n)
        coverage = top.sum() / df[col].notna().sum()
        print(f"\n  {col}  —  {n_unique:,} unique values")
        if n_unique > 100:
            print(f"    ⚠  High cardinality ({n_unique:,} unique) — may be an ID column")
        for val, cnt in top.items():
            bar = "█" * int(cnt / top.iloc[0] * 20)
            print(f"    {str(val)[:30]:<30} {bar:<20} {cnt:>8,} ({100*cnt/len(df):.1f}%)")
        if n_unique > top_n:
            print(f"    ... and {n_unique - top_n:,} more. Top-{top_n} cover {coverage:.1%} of non-null values.")


# =============================================================================
# 7. CORRELATION
# =============================================================================

def analyze_correlation(df: pd.DataFrame, columns: list[str], threshold: float = 0.7) -> None:
    if len(columns) < 2:
        return

    corr = df[columns].corr()
    print("\n" + "=" * 60)
    print(f"HIGH CORRELATIONS (|r| > {threshold})")
    print("=" * 60)

    found = False
    for i, c1 in enumerate(corr.columns):
        for c2 in corr.columns[i+1:]:
            r = corr.loc[c1, c2]
            if abs(r) >= threshold:
                direction = "🔴 +" if r > 0 else "🔵 -"
                print(f"  {direction}  {c1} ↔ {c2}:  r = {r:.3f}")
                found = True

    if not found:
        print(f"  ✅ No strong correlations found (threshold: {threshold})")


# =============================================================================
# 8. TARGET VARIABLE ANALYSIS
# =============================================================================

def analyze_target(df: pd.DataFrame, target: str) -> None:
    if target not in df.columns:
        print(f"  ⚠  Target column '{target}' not found")
        return

    print("\n" + "=" * 60)
    print(f"TARGET VARIABLE: {target}")
    print("=" * 60)

    col = df[target]

    if pd.api.types.is_numeric_dtype(col):
        print(f"  Type: Continuous (regression task)")
        print(f"  Mean:   {col.mean():.4g}")
        print(f"  Median: {col.median():.4g}")
        print(f"  Std:    {col.std():.4g}")
        print(f"  Zeros:  {(col == 0).sum():,} ({(col == 0).mean():.1%})")
        print(f"  Negatives: {(col < 0).sum():,}")
        if col.skew() > 1:
            print(f"  ⚠  Right-skewed (skew={col.skew():.2f}) — consider log1p transform")
    else:
        vc = col.value_counts()
        print(f"  Type: Categorical (classification task)")
        print(f"  Classes: {col.nunique()}")
        print(f"  Class balance:")
        for cls, cnt in vc.items():
            bar = "█" * int(cnt / vc.iloc[0] * 20)
            imbalance = " ⚠  (imbalanced)" if cnt / len(df) < 0.1 else ""
            print(f"    {str(cls):<20} {bar:<20} {cnt:>8,} ({100*cnt/len(df):.1f}%){imbalance}")


# =============================================================================
# 9. DATA QUALITY SCORE
# =============================================================================

def quality_score(df: pd.DataFrame) -> None:
    total_cells = df.shape[0] * df.shape[1]
    missing_cells = df.isnull().sum().sum()
    dup_rows = df.duplicated().sum()

    missing_score = max(0, 100 - (missing_cells / total_cells * 100))
    dup_score = max(0, 100 - (dup_rows / len(df) * 100))
    overall = (missing_score + dup_score) / 2

    print("\n" + "=" * 60)
    print("DATA QUALITY SCORE")
    print("=" * 60)
    print(f"  Completeness:  {missing_score:.0f}/100  ({total_cells - missing_cells:,}/{total_cells:,} cells filled)")
    print(f"  Uniqueness:    {dup_score:.0f}/100  ({len(df) - dup_rows:,}/{len(df):,} unique rows)")
    print(f"  Overall score: {overall:.0f}/100")
    rating = "🟢 Good" if overall >= 90 else "🟡 Fair" if overall >= 70 else "🔴 Poor"
    print(f"  Rating: {rating}")


# =============================================================================
# MAIN
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description="Exploratory Data Analysis")
    parser.add_argument("file", help="Path to data file (CSV, Excel, Parquet, JSON)")
    parser.add_argument("--target", help="Target/label column name")
    parser.add_argument("--sample", type=int, help="Sample N rows for large files")
    parser.add_argument("--output", help="Output HTML report path")
    parser.add_argument("--corr-threshold", type=float, default=0.7, help="Correlation threshold")
    args = parser.parse_args()

    df = load_data(args.file, args.sample)

    print_overview(df)
    col_types = analyze_types(df)
    analyze_missing(df)
    analyze_numeric(df, col_types["numeric"])
    analyze_categorical(df, col_types["text"])
    analyze_correlation(df, col_types["numeric"], args.corr_threshold)
    quality_score(df)

    if args.target:
        analyze_target(df, args.target)

    if args.output and HAS_PROFILING:
        print(f"\nGenerating HTML report: {args.output}")
        profile = yp.ProfileReport(df, title="EDA Report", explorative=True)
        profile.to_file(args.output)
        print("Done.")
    elif args.output:
        print("\n⚠  Install ydata-profiling for HTML reports: pip install ydata-profiling")

    print("\n✅ EDA complete.\n")


if __name__ == "__main__":
    main()
