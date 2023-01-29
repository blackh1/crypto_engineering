#include <iostream>
#include <immintrin.h>
#include <chrono>
#include <cstdint>
#include <random>
#include "aesni.h"
#include "myaes.h"
using namespace std;

void display(void* p, int len) {
	uint8_t* c = (uint8_t*)p;
	for (int i = 0; i < len; i++) printf("%02x ", c[i]);
	puts("");
}

void RAND_bytes(unsigned char* buf, int len) {
	static random_device rd;
	static uniform_int_distribution<int> dist(0, 255);
	for (int i = 0; i < len; i++) {
		buf[i] = static_cast<char>(dist(rd) & 0xFF);
	}
}

void verify() {
	// example in NIST file
	uint8_t KEY[16] = { 0x2b,0x7e,0x15,0x16,0x28,0xae,0xd2,0xa6,0xab,0xf7,0x15,0x88,0x09,0xcf,0x4f,0x3c };
	uint8_t IN[16] = { 0x32,0x43,0xf6,0xa8,0x88,0x5a,0x30,0x8d,0x31,0x31,0x98,0xa2,0xe0,0x37,0x07,0x34 };
	uint8_t true_OUT[16] = { 0x39,0x25,0x84,0x1d,0x02,0xdc,0x09,0xfb,0xdc,0x11,0x85,0x97,0x19,0x6a,0x0b,0x32 };
	uint8_t OUT[16];

	AESNI::AES_KEY_128 enc_key, dec_key;
	AESNI::AES128_set_encrypt_key(KEY, &enc_key);
	AESNI::AES128_set_decrypt_key(KEY, &dec_key);

	AESNI::AES128_encrypt(IN, OUT, &enc_key);
	if (memcmp(OUT, true_OUT, 16) != 0) {
		puts("AESNI implemention(encryption) is wrong.");
		return;
	}
		
	AESNI::AES128_decrypt(OUT, OUT, &dec_key);
	if (memcmp(OUT, IN, 16) != 0) {
		puts("AESNI implemention(decryption) is wrong.");
		return;
	}

	MYAES::AES_KEY_128 my_enc_key, my_dec_key;
	MYAES::AES128_set_encrypt_key(KEY, &my_enc_key);
	MYAES::AES128_set_decrypt_key(KEY, &my_dec_key);

	MYAES::AES128_encrypt(IN, OUT, &my_enc_key);
	if (memcmp(OUT, true_OUT, 16) != 0) {
		puts("My AES implemention(encryption) is wrong.");
		return;
	}
		
	MYAES::AES128_decrypt(OUT, OUT, &my_dec_key);
	if (memcmp(OUT, IN, 16) != 0) {
		puts("My AES implemention(decryption) is wrong.");
		return;
	}
		
	puts("Algorithms have been validated... all correct!");
}


void speed_test() {
	uint8_t key[16], in[16], out[16];
	int test_n = 100000;

	AESNI::AES_KEY_128 enc_key, dec_key;
	MYAES::AES_KEY_128 enc_key1, dec_key1;
	double aesni_enc_time = 0.0,
		aesni_dec_time = 0.0,
		myaes_enc_time = 0.0,
		myaes_dec_time = 0.0;

	for (int i = 0; i < test_n; i++) {
		RAND_bytes(key, 16);
		RAND_bytes(in, 16);

		AESNI::AES128_set_encrypt_key(key, &enc_key);
		AESNI::AES128_set_decrypt_key(key, &dec_key);
		MYAES::AES128_set_encrypt_key(key, &enc_key1);
		MYAES::AES128_set_encrypt_key(key, &dec_key1);

		auto begin = chrono::high_resolution_clock::now();
		AESNI::AES128_encrypt(in, out, &enc_key);
		auto end = chrono::high_resolution_clock::now();
		auto elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
		aesni_enc_time += elapsed.count();

		begin = chrono::high_resolution_clock::now();
		AESNI::AES128_decrypt(out, out, &dec_key);
		end = chrono::high_resolution_clock::now();
		elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
		aesni_dec_time += elapsed.count();

		begin = chrono::high_resolution_clock::now();
		MYAES::AES128_encrypt(in, out, &enc_key1);
		end = chrono::high_resolution_clock::now();
		elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
		myaes_enc_time += elapsed.count();

		begin = chrono::high_resolution_clock::now();
		MYAES::AES128_decrypt(out, out, &dec_key1);
		end = chrono::high_resolution_clock::now();
		elapsed = chrono::duration_cast<chrono::nanoseconds>(end - begin);
		myaes_dec_time += elapsed.count();
	}
	printf("%d Times AESNI Encryption: %.5f seconds.\n", test_n, aesni_enc_time * 1e-9);
	printf("%d Times AESNI Decryption: %.5f seconds.\n", test_n, aesni_dec_time * 1e-9);
	printf("%d Times MYAES Encryption: %.5f seconds.\n", test_n, myaes_enc_time * 1e-9);
	printf("%d Times MYAES Decryption: %.5f seconds.\n", test_n, myaes_dec_time * 1e-9);

}


int main()
{
	verify();
	speed_test();

	return 0;
}
