"""
This file computes the n-th pancake number, where n is passed in as a command line argument. This algorithm is not optimized. It works in reverse; starting with a sorted stack of pancakes and iteratively flipping it at each possible position until all n! permutations of the list are created.
"""
from math import factorial
import sys

# Reading in inputs
n = int(sys.argv[1])

def flip(x, a):
    flipped = x[0:a]
    flipped = flipped[::-1]
    x = x[a:]
    return flipped + x

current = {tuple(range(1, n + 1))}

max_needed = factorial(n)
pancake_number = 0

while len(current) < max_needed:
    length = len(current)
    next_set = set()
    for i in range(2, n + 1):
        for stack in current:
            next = flip(stack, i)
            if next not in current:
                next_set.add(next)
    current = current | next_set
    
    pancake_number += 1

print(f"{n} -> {pancake_number}")
