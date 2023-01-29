#include <iostream>
#include <cmath>
#include <string>
#include <chrono>
using namespace std;
typedef long long ll;


string str_m = "5886653046039615242",
	   str_c = "3285466232066392810",
	   str_n = "12215813158503973699",
       str_p = "3141424073",
       str_q = "3888622763",
	   str_e = "3728270764079689623",
	   str_d = "11874218063014542007";

/*   // Test Parameters：
string str_m = "6815828386955665684", 
	   str_c = "6080290118804345840", 
	   str_n = "10808042027768483209",
	   str_p = "4016362699",
	   str_q = "2691002491",
	   str_e = "9171027428608763191",
	   str_d = "9384184634300998831";
*/
inline __int128 toInt128(string s) {
	int l = s.length();
	__int128 m = 0;
	for (int i = 0; i < l; i++) {
		m *= 10;
		m += s[i] - 48;
	}
	return m;
}

inline void print(__int128 x) {
	if (x < 0) {
		putchar('-');
		x = -x;
	}
	if (x > 9) print(x / 10);
	putchar(x % 10 + '0');
}

inline __int128 qpow(__int128 x, __int128 y, __int128 mod) {
	__int128 res = 1;
	for (x %= mod; y; y >>= 1, x = x * x % mod) if (y & 1) res = res * x % mod;
	return res;
}

inline void exgcd(__int128 a, __int128 b, __int128& x, __int128& y) {
	if (!b) x = 1, y = 0;
	else exgcd(b, a % b, y, x), y -= x * (a / b);
}

inline __int128 inverse(__int128 a, __int128 n) {
	__int128 x, y;
	exgcd(a, n, x, y);
	return (x % n + n) % n;
}


int main()
{
	__int128 p = toInt128(str_p), q = toInt128(str_q), e = toInt128(str_e), d = toInt128(str_d);
	__int128 m = toInt128(str_m), c = toInt128(str_c), n = toInt128(str_n);

	/*  plain RSA  */
	auto begin = chrono::high_resolution_clock::now();
	for (int i = 0; i < 100000; i++) m = qpow(c, d, n);
	auto end = chrono::high_resolution_clock::now();

	auto elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
	printf("Time measured: %.5f seconds.\n", elapsed.count() * 1e-9);
	cout << "normal RSA decryption m = "; print(m); puts("");

	/*  accelerated RSA  */
	// precompute
	__int128 d1 = d % (p - 1), d2 = d % (q - 1);
	__int128 inv = inverse(p, q);

	begin = chrono::high_resolution_clock::now();
	for (int i = 0; i < 100000; i++) {
		__int128 m1 = qpow(c, d1, p);
		__int128 m2 = qpow(c, d2, q);
		m = m1 + ((m2 - m1) * inv % q) * p;
	}
	end = chrono::high_resolution_clock::now();

	elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
	printf("Time measured: %.5f seconds.\n", elapsed.count() * 1e-9);
	cout << "accelerated RSA decryption m = "; print(m); puts("");

	return 0;
}
