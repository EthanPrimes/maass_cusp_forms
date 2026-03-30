from sage.libs.pari import pari

def process_disc_proven(D):
    bnf = pari(f"bnfinit(x^2 - {D}, 1)")
    return int(pari(f"bnf.clgp.no"))

print(process_disc_proven(int(input())))
