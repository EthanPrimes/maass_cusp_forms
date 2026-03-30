"""
merge_shards.py

Concatenates result shard feather files into a single output feather file.

Usage:
    python merge_shards.py [--indir output] [--out class_numbers_final.feather]
"""

import argparse
import glob
import os
import pyarrow as pa
import pyarrow.feather as feather


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--indir", type=str, default="output",
                        help="Directory containing result_XXXXX.feather shards (default: output)")
    parser.add_argument("--out", type=str, default="class_numbers_final.feather",
                        help="Output feather file path (default: class_numbers_final.feather)")
    args = parser.parse_args()

    pattern = os.path.join(args.indir, "result_*.feather")
    shard_paths = sorted(glob.glob(pattern))

    if not shard_paths:
        print(f"No shard files found matching: {pattern}")
        return

    print(f"Found {len(shard_paths)} shards. Reading...")
    shards = [feather.read_table(p) for p in shard_paths]

    print("Concatenating...")
    combined = pa.concat_tables(shards)

    print(f"Writing {len(combined)} rows to {args.out}...")
    feather.write_feather(combined, args.out)

    print("Done.")


if __name__ == "__main__":
    main()
