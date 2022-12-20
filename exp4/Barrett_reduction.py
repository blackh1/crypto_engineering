# Barrett Reduction
from math import ceil, log2
from random import randint

bit_of_a = 1023
a = randint(2 ** (bit_of_a - 1) + 1, 2 ** bit_of_a - 1)
# n is a 1020-bit prime number.
n = 8862981350823119266272197009064278445415307632595928723347629268121697357234371459742688614077295974018358517166858633371548905750068422858577850776270858439078636697315129123891222696150100229109810079155135885038988834744436834378187222206460578793333037988816236152195003821384440333336888624918459374839
k = ceil(log2((n-1)*a))  # choice of k is important for correctness of the algorithm
m = ceil(2**k/n)  # precompute

def barRedc(a, n):
    q = (a * m) >> k
    a -= q * n
    if a >= n:
        a -= n
    return a

if __name__ == '__main__':
    print('The result of plain method:', a % n, sep='\n')
    print('The result of Barrett Reduction:', barRedc(a, n), sep='\n')
