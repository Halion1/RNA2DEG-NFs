#!/usr/bin/env python3
"""
build_samplesheet_basic.py
--------------------------
Generate samplesheet_basic.csv from an md5 list file.

Input:
  - md5 list file (one line per file), with at least:
      filename, basename, md5, path
    separated by tabs or multiple spaces.
  - mode: "both", "pair", or "single"

Output:
  - samplesheet_basic.csv with columns:
      id, name1, fastq1, name2, fastq2, SoP
    where SoP is "PAIR" or "SINGLE".
"""

import argparse
import csv
import re
import sys
from pathlib import Path


def require_file(path: str, label: str = "file") -> str:
    """Ensure the given file exists; exit with a clear message if not."""
    p = Path(path)
    if not p.exists():
        sys.exit(f"[OBTAININGCSV] Missing {label}: {path}")
    return str(p.resolve())


def parse_md5list(md5_path: Path) -> dict:
    """
    Parse the md5 list file and return a dict:
        samples[sid][mate] = (basename, path)

    mate is 1 or 2 for paired-end naming conventions.
    """
    samples = {}

    with md5_path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            # First try splitting on tabs or runs of >=2 spaces
            parts = re.split(r"\t+|\s{2,}", line)
            if len(parts) < 4:
                # Fallback to generic whitespace split
                parts = line.split()
                if len(parts) < 4:
                    # Skip malformed lines
                    continue

            filename, basename, md5, path = parts[0], parts[1], parts[2], parts[3]

            # Try to detect pattern: <sample_id>_<mate>, where mate is 1 or 2
            m = re.fullmatch(r"(?P<id>.+)_(?P<mate>[12])", basename)
            if not m:
                # No mate number in basename → treat as generic sample id
                sid = basename
                samples.setdefault(sid, {})
                # Try to fill mate 1 first, then mate 2 if missing
                if 1 not in samples[sid]:
                    name1 = basename if "_" in basename else f"{basename}_1"
                    samples[sid][1] = (name1, path)
                elif 2 not in samples[sid]:
                    name2 = basename if "_" in basename else f"{basename}_2"
                    samples[sid][2] = (name2, path)
                continue

            sid = m.group("id")
            mate = int(m.group("mate"))
            samples.setdefault(sid, {})
            samples[sid][mate] = (basename, path)

    return samples


def write_samplesheet(samples: dict, mode: str, out_path: Path) -> int:
    """
    Write the samplesheet_basic.csv file according to the mode.
    Returns the number of rows written (excluding header).
    """
    mode = mode.lower()
    valid_modes = {"both", "pair", "single"}
    if mode not in valid_modes:
        sys.exit(f"[OBTAININGCSV] Invalid mode '{mode}'. "
                 f"Expected one of: {', '.join(sorted(valid_modes))}")

    rows_written = 0

    with out_path.open("w", newline="") as out:
        w = csv.writer(out)
        w.writerow(["id", "name1", "fastq1", "name2", "fastq2", "SoP"])

        for sid in sorted(samples):
            m1 = samples[sid].get(1)
            m2 = samples[sid].get(2)

            # Paired-end rows
            if mode in {"both", "pair"} and m1 and m2:
                w.writerow([sid, m1[0], m1[1], m2[0], m2[1], "PAIR"])
                rows_written += 1

            # Single-end rows
            if mode in {"both", "single"}:
                if m1:
                    w.writerow([sid, m1[0], m1[1], "null", "null", "SINGLE"])
                    rows_written += 1
                elif m2:
                    w.writerow([sid, m2[0], m2[1], "null", "null", "SINGLE"])
                    rows_written += 1

    return rows_written


def main():
    parser = argparse.ArgumentParser(
        description="Generate samplesheet_basic.csv from md5 list."
    )
    parser.add_argument(
        "--md5list",
        required=True,
        help="Path to md5 list file (filename, basename, md5, path).",
    )
    parser.add_argument(
        "--mode",
        required=True,
        help="Mode: both, pair, or single.",
    )
    parser.add_argument(
        "--out",
        default="samplesheet_basic.csv",
        help="Output CSV file (default: samplesheet_basic.csv).",
    )

    args = parser.parse_args()

    md5_path = Path(require_file(args.md5list, "md5 list"))
    out_path = Path(args.out)

    samples = parse_md5list(md5_path)
    n_rows = write_samplesheet(samples, args.mode, out_path)

    print(f"[OBTAININGCSV] Wrote {n_rows} rows to {out_path.resolve()}")


if __name__ == "__main__":
    main()

