import sys

# command line arguments
start = int(sys.argv[1])   # 1-based index
end   = int(sys.argv[2])

def process_disc(D):
    """
    Takes in a fundamental discriminant D and returns the class number.
    """
    return QuadraticField(D, "x").class_number()

with open("fundamental_discriminants.jsonl") as f:
    for idx, line in enumerate(f, start=1):  # idx = 1, 2, 3, ...
        if idx < start:
            continue
        if idx > end:
            break

        D = int(line.strip())  # raw integer -> discriminant
        result = process_disc(D)
        print(D, result)
