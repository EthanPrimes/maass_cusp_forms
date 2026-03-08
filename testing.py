import pandas as pd

res = pd.read_feather("discriminants.feather")
print(res.columns)
print(res.head)