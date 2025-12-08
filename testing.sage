# import sys

# if len(sys.argv) > 1:
#     print(f"First input: {sys.argv[1]}")
# else:
#     print("No arguments provided.")

K = QuadraticField(15, "x")
print(K.class_number())
