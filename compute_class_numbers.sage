#!/usr/bin/env sage
"""
compute_class_numbers.sage

Reads a slice of discriminants from a Feather file (by row index),
computes the provably correct class number h(D) for each real quadratic
field Q(sqrt(D)), and writes the results to a shard Feather file.

Usage:
    sage compute_class_numbers.sage \
        --job-id JOB_ID \
        --start START \
        --end END \
        [--input discriminants.feather] \
        [--outdir output]
"""

import argparse
import time
import os

import pyarrow as pa
import pyarrow.feather as feather
import pandas as pd


def process_disc(D):
    """
    Takes in a fundamental discriminant D and returns the class number h(D).
    Uses Sage's QuadraticField, which is provably correct via the PARI backend.
    """
    return QuadraticField(D, "x").class_number()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--job-id", type=int, required=True,
                        help="SLURM array task ID (used for output filename)")
    parser.add_argument("--start", type=int, required=True,
                        help="First row index into the feather file (inclusive)")
    parser.add_argument("--end", type=int, required=True,
                        help="Last row index into the feather file (exclusive)")
    parser.add_argument("--input", type=str, default="discriminants.feather",
                        help="Path to the input feather file")
    parser.add_argument("--outdir", type=str, default="output",
                        help="Directory to write result shards into")
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)

    # --- Load only the needed slice from the feather file ---
    # Read the full column once; pyarrow is fast and columnar so this is
    # efficient even for tens of millions of rows.
    table = feather.read_table(args.input, columns=["D"])
    discriminants = table["D"].to_pylist()[args.start:args.end]

    if not discriminants:
        print(f"No discriminants found in row range [{args.start}, {args.end}).")
        return

    print(f"Job {args.job_id}: processing rows {args.start}–{args.end - 1} "
          f"({len(discriminants)} discriminants).")

    start_time = time.time()

    result_D = []
    result_h = []
    failed = []

    for D in discriminants:
        try:
            h = process_disc(D)
            result_D.append(int(D))
            result_h.append(int(h))
        except Exception as e:
            failed.append((int(D), str(e)))

    runtime = time.time() - start_time

    # --- Write output shard as feather ---
    out_table = pa.table({
        "D": pa.array(result_D, type=pa.int64()),
        "class_number": pa.array(result_h, type=pa.int64()),
    })
    outfile = os.path.join(args.outdir, f"result_{args.job_id:05d}.feather")
    feather.write_feather(out_table, outfile)

    # --- Report any failures to stderr for SLURM error logs ---
    if failed:
        import sys
        print(f"Job {args.job_id}: {len(failed)} discriminants failed:", file=sys.stderr)
        for D, err in failed:
            print(f"  D={D}: {err}", file=sys.stderr)

    print(f"Job {args.job_id}: wrote {len(result_D)} results to {outfile}.")
    print(f"Job {args.job_id}: runtime {runtime:.2f} seconds.")


if __name__ == "__main__":
    main()
