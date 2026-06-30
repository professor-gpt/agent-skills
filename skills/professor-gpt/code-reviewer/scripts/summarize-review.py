#!/usr/bin/env python3
"""
summarize-review.py
-------------------
Parse a code review markdown output and produce a structured JSON summary
with issue counts by severity, a risk score, and a merge decision.

Usage:
    python summarize-review.py review.md
    python summarize-review.py review.md --json
    cat review.md | python summarize-review.py -
"""

import re
import sys
import json
import argparse
from dataclasses import dataclass, asdict
from typing import Optional


SEVERITY_WEIGHTS = {
    "CRITICAL": 100,
    "HIGH":      30,
    "MEDIUM":    10,
    "LOW":        2,
    "INFO":       0,
}

MERGE_THRESHOLDS = {
    "BLOCK":   lambda c: c["CRITICAL"] > 0 or c["HIGH"] > 2,
    "REVIEW":  lambda c: c["HIGH"] > 0 or c["MEDIUM"] > 3,
    "APPROVE": lambda c: True,
}


@dataclass
class ReviewSummary:
    total_issues: int
    by_severity: dict[str, int]
    risk_score: int
    merge_decision: str
    top_issues: list[str]
    files_reviewed: int


def parse_severity_counts(text: str) -> dict[str, int]:
    """Count occurrences of each severity tag in the review text."""
    counts = {sev: 0 for sev in SEVERITY_WEIGHTS}
    # Match patterns like: [CRITICAL], [HIGH], #### [HIGH], **[MEDIUM]**
    pattern = r'\[(' + '|'.join(SEVERITY_WEIGHTS.keys()) + r')\]'
    for match in re.finditer(pattern, text, re.IGNORECASE):
        sev = match.group(1).upper()
        counts[sev] += 1
    return counts


def extract_top_issues(text: str, limit: int = 5) -> list[str]:
    """Extract the first sentence of each issue description."""
    issues = []
    # Match heading patterns like: #### [CRITICAL] SQL Injection — Line 3
    pattern = r'#{1,4}\s+\[(?:CRITICAL|HIGH|MEDIUM|LOW|INFO)\]\s+(.+)'
    for match in re.finditer(pattern, text, re.IGNORECASE):
        issues.append(match.group(1).strip())
        if len(issues) >= limit:
            break
    return issues


def count_files(text: str) -> int:
    """Estimate number of files reviewed from code block filenames."""
    pattern = r'```\w*\s*\n(?:#|//|--)\s*([\w./\\-]+\.\w+)'
    files = set(re.findall(pattern, text))
    return max(1, len(files))


def calculate_risk_score(counts: dict[str, int]) -> int:
    score = sum(SEVERITY_WEIGHTS[sev] * cnt for sev, cnt in counts.items())
    return min(score, 1000)  # cap at 1000


def determine_merge_decision(counts: dict[str, int]) -> str:
    if MERGE_THRESHOLDS["BLOCK"](counts):
        return "BLOCK — Fix CRITICAL/HIGH issues before merge"
    if MERGE_THRESHOLDS["REVIEW"](counts):
        return "REQUEST CHANGES — Address HIGH/MEDIUM issues"
    return "APPROVE — No blocking issues found"


def analyze_review(text: str) -> ReviewSummary:
    counts = parse_severity_counts(text)
    total = sum(counts.values())
    risk = calculate_risk_score(counts)
    decision = determine_merge_decision(counts)
    top = extract_top_issues(text)
    files = count_files(text)
    return ReviewSummary(
        total_issues=total,
        by_severity=counts,
        risk_score=risk,
        merge_decision=decision,
        top_issues=top,
        files_reviewed=files,
    )


def format_text(summary: ReviewSummary) -> str:
    lines = [
        "=" * 50,
        "CODE REVIEW SUMMARY",
        "=" * 50,
        f"Total Issues    : {summary.total_issues}",
        f"Risk Score      : {summary.risk_score}/1000",
        f"Files Reviewed  : {summary.files_reviewed}",
        "",
        "By Severity:",
    ]
    for sev in ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO"]:
        count = summary.by_severity[sev]
        bar = "█" * count + "░" * max(0, 5 - count)
        lines.append(f"  {sev:<10} {bar}  {count}")
    lines += [
        "",
        f"Decision: {summary.merge_decision}",
        "",
        "Top Issues:",
    ]
    for i, issue in enumerate(summary.top_issues, 1):
        lines.append(f"  {i}. {issue}")
    if not summary.top_issues:
        lines.append("  (none found)")
    lines.append("=" * 50)
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Summarize a code review markdown file")
    parser.add_argument("file", help="Path to review markdown file (use - for stdin)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    if args.file == "-":
        text = sys.stdin.read()
    else:
        with open(args.file, encoding="utf-8") as f:
            text = f.read()

    summary = analyze_review(text)

    if args.json:
        print(json.dumps(asdict(summary), indent=2))
    else:
        print(format_text(summary))


if __name__ == "__main__":
    main()
