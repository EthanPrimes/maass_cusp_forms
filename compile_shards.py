import pyarrow.feather as feather
import pyarrow as pa
import glob

shards = [feather.read_table(f) for f in sorted(glob.glob("output/result_*.feather"))]
feather.write_feather(pa.concat_tables(shards), "class_numbers_final.feather")
