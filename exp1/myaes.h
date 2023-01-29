#pragma once
#include <cstdint>

namespace MYAES {
    struct AES_KEY_128 {
        __declspec(align(16)) uint32_t rd_key[4 * (10 + 1)];
    };

    inline uint32_t SubWord(uint32_t w);
    inline uint32_t iSubWord(uint32_t w);
	inline uint32_t RotWord(uint32_t x);
	void Gen_round_key(uint32_t* k0, uint32_t* k1, int round);
	inline uint8_t Mul2(uint8_t x);
	uint8_t Mul3(uint8_t x);
	uint8_t Mul4(uint8_t x);
	uint8_t Mul8(uint8_t x);
	uint8_t Mul9(uint8_t x);
	uint8_t Mulb(uint8_t x);
	uint8_t Muld(uint8_t x);
	uint8_t Mule(uint8_t x);

    int AES128_set_encrypt_key(const unsigned char* userKey, AES_KEY_128* key);
    int AES128_set_decrypt_key(const unsigned char* userKey, AES_KEY_128* key);
    void AES128_encrypt(const uint8_t* in, uint8_t* out, const AES_KEY_128* key);
    void AES128_decrypt(const uint8_t* in, uint8_t* out, const AES_KEY_128* key);
}
