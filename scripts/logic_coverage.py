#!/usr/bin/env python3
"""Report FocusUp logic coverage from an xcodebuild .xcresult bundle."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path


def load_policy(policy_path: Path) -> dict:
    with policy_path.open(encoding="utf-8") as handle:
        return json.load(handle)


def xccov_json(result_bundle: Path) -> dict:
    proc = subprocess.run(
        ["xcrun", "xccov", "view", "--report", "--json", str(result_bundle)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(proc.stdout)


def focusup_files(report: dict) -> list[dict]:
    for target in report.get("targets", []):
        if target.get("name") == "FocusUp.app":
            return target.get("files", [])
    raise SystemExit("FocusUp.app target not found in coverage report.")


def file_path(entry: dict) -> str:
    return entry.get("path") or entry.get("name") or ""


def normalize_path(path: str) -> str:
    marker = "/FocusUp/"
    if marker in path:
        return "FocusUp/" + path.rsplit(marker, 1)[1]
    return Path(path).name


def matches_any(text: str, patterns: list[str]) -> bool:
    return any(pattern in text for pattern in patterns)


def is_logic_file(path: str, policy: dict) -> bool:
    normalized = normalize_path(path)
    prefixes = policy.get("include_prefixes", [])
    if prefixes and not any(normalized.startswith(prefix) for prefix in prefixes):
        return False
    if matches_any(path, policy.get("exclude_patterns", [])) or matches_any(
        normalized, policy.get("exclude_patterns", [])
    ):
        return False
    basename = Path(path).name
    for suffix in policy.get("exclude_suffixes", []):
        if basename.endswith(suffix):
            return False
    return True


def summarize(files: list[dict], predicate) -> tuple[float, int, int]:
    total = 0
    covered = 0
    for entry in files:
        if not predicate(file_path(entry)):
            continue
        lines = int(entry.get("executableLines", 0))
        if lines == 0:
            continue
        total += lines
        covered += int(lines * float(entry.get("lineCoverage", 0)))
    percent = (100.0 * covered / total) if total else 0.0
    return percent, covered, total


def github_step_summary(lines: list[str]) -> None:
    summary = __import__("os").environ.get("GITHUB_STEP_SUMMARY")
    if not summary:
        return
    with open(summary, "a", encoding="utf-8") as handle:
        handle.write("\n".join(lines))
        handle.write("\n")


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("Usage: logic_coverage.py <TestResults.xcresult> [coverage_policy.toml]", file=sys.stderr)
        return 2

    result_bundle = Path(argv[1]).resolve()
    policy_path = Path(argv[2]).resolve() if len(argv) > 2 else Path(__file__).with_name("coverage_policy.json")
    policy = load_policy(policy_path)

    files = focusup_files(xccov_json(result_bundle))
    total_pct, total_cov, total_lines = summarize(files, lambda _: True)
    logic_pct, logic_cov, logic_lines = summarize(files, lambda p: is_logic_file(p, policy))

    minimum_logic = float(policy.get("minimum_logic_coverage", 80.0))
    minimum_total = float(policy.get("minimum_total_coverage", 0.0))

    print("FocusUp coverage summary")
    print(f"  Total app target: {total_pct:.1f}% ({total_cov:,}/{total_lines:,} lines)")
    print(f"  Logic coverage:   {logic_pct:.1f}% ({logic_cov:,}/{logic_lines:,} lines)")
    print(f"  Logic gate:       >= {minimum_logic:.1f}%")

    summary_lines = [
        "## iOS coverage",
        "",
        "| Metric | Coverage | Lines |",
        "|--------|----------|-------|",
        f"| **Logic (CI gate)** | **{logic_pct:.1f}%** | {logic_cov:,}/{logic_lines:,} |",
        f"| Total app target | {total_pct:.1f}% | {total_cov:,}/{total_lines:,} |",
        "",
        f"Logic gate threshold: **{minimum_logic:.1f}%**",
        "",
        "_Logic coverage excludes SwiftUI views, design system, previews, and test fixtures._",
    ]
    github_step_summary(summary_lines)

    failed = False
    if logic_pct + 1e-9 < minimum_logic:
        print(f"ERROR: Logic coverage {logic_pct:.1f}% is below minimum {minimum_logic:.1f}%.", file=sys.stderr)
        failed = True
    if minimum_total > 0 and total_pct + 1e-9 < minimum_total:
        print(f"ERROR: Total coverage {total_pct:.1f}% is below minimum {minimum_total:.1f}%.", file=sys.stderr)
        failed = True

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
