import re
import os

files = os.listdir(".")
indices = {int(m.group(1)) for f in files if (m := re.search(r"result_(\d+)\.feather", f))}
expected = set(range(min(indices), max(indices) + 1))
missing = sorted(expected - indices)

print(f"Missing indices ({len(missing)} total): {missing}")
