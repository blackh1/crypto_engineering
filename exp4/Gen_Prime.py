from random import randint

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


if __name__ == '__main__':
    print(generate_prime(1024))
