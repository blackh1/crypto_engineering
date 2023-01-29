from random import randint
from math import gcd

test_prime = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]


def Miller_Rabin(N):
    if N < 2: return False
    if N in test_prime: return True
    if N % 2 == 0: return False
    t = N - 1
    k = 0
    while t % 2 == 0:
        t >>= 1
        k += 1
    for a in test_prime:
        x = pow(a, t, N)
        cnt = 0
        while cnt < k:
            nxt = x * x % N
            if nxt == 1 and x != 1 and x != N - 1:
                return False
            x = nxt
            cnt += 1
        if cnt == k and nxt != 1:
            return False
    return True


def generate_prime(bit):
    while True:
        x = randint(2 ** (bit - 1) + 1, 2 ** bit - 1)
        if Miller_Rabin(x):
            return x

def findModInverse(x, N):
    u1, u2, u3 = 1, 0, x
    v1, v2, v3 = 0, 1, N
    while v3 != 0:
        tmp = u3 // v3
        v1, v2, v3, u1, u2, u3 = (u1 - tmp * v1), (u2 - tmp * v2), (u3 - tmp * v3), v1, v2, v3
    return u1 % N



if __name__ == '__main__':
    ''' # input in 128 bit format:

    m = randint(2 ** (63 - 1) + 1, 2 ** 63 - 1)
    p = generate_prime(32)
    q = generate_prime(32)
    n = p * q
    phi_n = (p-1)*(q-1)

    while True:
        e = randint(2 ** (62 - 1) + 1, 2 ** 63 - 1)
        if gcd(e, phi_n) == 1:
            d = findModInverse(e, phi_n)
            break 
    
    c = pow(m, e, n)

    print('ss_m = \"', m,'",',sep='')
    print('ss_c = \"', c,'",',sep='')
    print('ss_n = \"', n,'",',sep='')
    print('ss_p = \"', p,'",',sep='')
    print('ss_q = \"', q,'",',sep='')
    print('ss_e = \"', e,'",',sep='')
    print('ss_d = \"', d,'";',sep='')
    '''

    m = randint(2 ** (1023 - 1) + 1, 2 ** 1023 - 1)
    p = generate_prime(512)
    q = generate_prime(512)
    n = p * q
    phi_n = (p-1)*(q-1)

    while True:
        e = randint(2 ** (1022 - 1) + 1, 2 ** 1023 - 1)
        if gcd(e, phi_n) == 1:
            d = findModInverse(e, phi_n)
            break 
    
    c = pow(m, e, n)

    print('m("', m,'"),',sep='')
    print('c("', c,'"),',sep='')
    print('n("', n,'"),',sep='')
    print('p("', p,'"),',sep='')
    print('q("', q,'"),',sep='')
    print('e("', e,'"),',sep='')
    print('d("', d,'");',sep='')
