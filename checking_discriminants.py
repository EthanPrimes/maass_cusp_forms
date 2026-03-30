# import pyarrow.feather as feather

# table = feather.read_table("discriminants.feather", columns=["D"])
# col = table["D"]
# print(f"Total discriminants: {len(col)}")
# print(f"Min D: {col[0].as_py()}")
# print(f"Max D: {col[-1].as_py()}")

import pyarrow.feather as feather

table = feather.read_table("class_numbers_unproven.feather", columns=["D"])
col = table["D"]
print(f"Total discriminants: {len(col)}")
print(f"Min D: {col[0].as_py()}")
print(f"Max D: {col[-1].as_py()}")
