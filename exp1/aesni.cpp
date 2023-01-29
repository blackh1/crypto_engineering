#include "aesni.h"
#include <immintrin.h>
#include <emmintrin.h>
#include <cstring>

namespace AESNI {
    template<const int rcon>
    static inline void AES_128_key_exp(__m128i k0, __m128i& k1) {
        __m128i core = _mm_shuffle_epi32(_mm_aeskeygenassist_si128(k0, rcon), _MM_SHUFFLE(3, 3, 3, 3));
        k1 = _mm_xor_si128(k0, _mm_slli_si128(k0, 4));
        k1 = _mm_xor_si128(k1, _mm_slli_si128(k1, 8));
        k1 = _mm_xor_si128(k1, core);
    }

    int AES128_set_encrypt_key(const unsigned char* userKey, AES_KEY_128* key) {
        if (!userKey || !key) return -1;

        __m128i* rk128 = reinterpret_cast<__m128i*>(key->rd_key);

        memcpy(rk128, userKey, 16);
        AES_128_key_exp<0x01>(rk128[0], rk128[1]);
        AES_128_key_exp<0x02>(rk128[1], rk128[2]);
        AES_128_key_exp<0x04>(rk128[2], rk128[3]);
        AES_128_key_exp<0x08>(rk128[3], rk128[4]);
        AES_128_key_exp<0x10>(rk128[4], rk128[5]);
        AES_128_key_exp<0x20>(rk128[5], rk128[6]);
        AES_128_key_exp<0x40>(rk128[6], rk128[7]);
        AES_128_key_exp<0x80>(rk128[7], rk128[8]);
        AES_128_key_exp<0x1B>(rk128[8], rk128[9]);
        AES_128_key_exp<0x36>(rk128[9], rk128[10]);

        return 0;
    }

    int AES128_set_decrypt_key(const unsigned char* userKey, AES_KEY_128* key) {
        if (!userKey || !key) return -1;

        __m128i* rk128 = reinterpret_cast<__m128i*>(key->rd_key);

        memcpy(&(rk128[10]), userKey, 16);
        AES_128_key_exp<0x01>(rk128[10], rk128[9]);
        AES_128_key_exp<0x02>(rk128[9], rk128[8]);
        rk128[9] = _mm_aesimc_si128(rk128[9]);
        AES_128_key_exp<0x04>(rk128[8], rk128[7]);
        rk128[8] = _mm_aesimc_si128(rk128[8]);
        AES_128_key_exp<0x08>(rk128[7], rk128[6]);
        rk128[7] = _mm_aesimc_si128(rk128[7]);
        AES_128_key_exp<0x10>(rk128[6], rk128[5]);
        rk128[6] = _mm_aesimc_si128(rk128[6]);
        AES_128_key_exp<0x20>(rk128[5], rk128[4]);
        rk128[5] = _mm_aesimc_si128(rk128[5]);
        AES_128_key_exp<0x40>(rk128[4], rk128[3]);
        rk128[4] = _mm_aesimc_si128(rk128[4]);
        AES_128_key_exp<0x80>(rk128[3], rk128[2]);
        rk128[3] = _mm_aesimc_si128(rk128[3]);
        AES_128_key_exp<0x1B>(rk128[2], rk128[1]);
        rk128[2] = _mm_aesimc_si128(rk128[2]);
        AES_128_key_exp<0x36>(rk128[1], rk128[0]);
        rk128[1] = _mm_aesimc_si128(rk128[1]);

        return 0;
    }

    void AES128_encrypt(const unsigned char* in, unsigned char* out, const AES_KEY_128* key) {
        __m128i m = _mm_loadu_si128((__m128i*) in);
        const __m128i* rk128 = reinterpret_cast<const __m128i*>(key->rd_key);

        m = _mm_xor_si128(m, rk128[0]);
        m = _mm_aesenc_si128(m, rk128[1]);
        m = _mm_aesenc_si128(m, rk128[2]);
        m = _mm_aesenc_si128(m, rk128[3]);
        m = _mm_aesenc_si128(m, rk128[4]);
        m = _mm_aesenc_si128(m, rk128[5]);
        m = _mm_aesenc_si128(m, rk128[6]);
        m = _mm_aesenc_si128(m, rk128[7]);
        m = _mm_aesenc_si128(m, rk128[8]);
        m = _mm_aesenc_si128(m, rk128[9]);
        m = _mm_aesenclast_si128(m, rk128[10]);

        _mm_storeu_si128((__m128i*) out, m);
    }

    void AES128_decrypt(const unsigned char* in, unsigned char* out, const AES_KEY_128* key) {
        __m128i m = _mm_loadu_si128((__m128i*) in);
        const __m128i* rk128 = reinterpret_cast<const __m128i*>(key->rd_key);

        m = _mm_xor_si128(m, rk128[0]);
        m = _mm_aesdec_si128(m, rk128[1]);
        m = _mm_aesdec_si128(m, rk128[2]);
        m = _mm_aesdec_si128(m, rk128[3]);
        m = _mm_aesdec_si128(m, rk128[4]);
        m = _mm_aesdec_si128(m, rk128[5]);
        m = _mm_aesdec_si128(m, rk128[6]);
        m = _mm_aesdec_si128(m, rk128[7]);
        m = _mm_aesdec_si128(m, rk128[8]);
        m = _mm_aesdec_si128(m, rk128[9]);
        m = _mm_aesdeclast_si128(m, rk128[10]);

        _mm_storeu_si128((__m128i*) out, m);
    }
}
