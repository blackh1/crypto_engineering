#pragma once
#include <cstdint>



namespace AESNI {
    struct AES_KEY_128 {
        __declspec(align(16)) uint32_t rd_key[4 * (10 + 1)];
    };

    int AES128_set_encrypt_key(const unsigned char* userKey, AES_KEY_128* key);
    int AES128_set_decrypt_key(const unsigned char* userKey, AES_KEY_128* key);
    void AES128_encrypt(const unsigned char* in, unsigned char* out, const AES_KEY_128* key);
    void AES128_decrypt(const unsigned char* in, unsigned char* out, const AES_KEY_128* key);
}

