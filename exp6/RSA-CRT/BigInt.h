#pragma once
#include <iostream>
#include <vector>

class BigInt
{
#define Value(x, nega) ((nega) ? -(x) : (x))
#define At(vec, index) ((index) < vec.size() ? vec[(index)] : 0)
private:
    static int absComp(const BigInt& lhs, const BigInt& rhs);
    using Long = long long;
    const static int Exp = 4;
    const static Long Mod = 10000;
    mutable std::vector<Long> val;
    mutable bool nega = false;

    void trim() const;
    int size() const;
    Long& operator[](int index) const;
    Long& back() const;
    BigInt(int size, bool nega);
    BigInt(const std::vector<Long>& val, bool nega);

public:
    friend std::ostream& operator<<(std::ostream& os, const BigInt& n);
    friend BigInt operator+(const BigInt& lhs, const BigInt& rhs);
    friend BigInt operator-(const BigInt& lhs, const BigInt& rhs);
    BigInt(Long x = 0);
    BigInt(const char* s);

    BigInt& operator=(const char* s);
    BigInt& operator=(const Long x);
    friend std::istream& operator>>(std::istream& is, BigInt& n);
    BigInt& operator+=(const BigInt& rhs);
    friend BigInt operator-(const BigInt& rhs);
    BigInt& operator-=(const BigInt& rhs);

    friend BigInt operator*(const BigInt& lhs, const BigInt& rhs);
    friend BigInt operator*(const BigInt& lhs, const Long& x);
    BigInt& operator*=(const BigInt& rhs);
    BigInt& operator*=(const Long& x);

    friend BigInt operator/(const BigInt& lhs, const BigInt& rhs);
    friend BigInt operator/(const BigInt& num, const Long& x);
    friend BigInt operator%(const BigInt& lhs, const BigInt& rhs);

    bool operator==(const BigInt& rhs) const;
    bool operator!=(const BigInt& rhs) const;
    bool operator>=(const BigInt& rhs) const;
    bool operator>(const BigInt& rhs) const;
    bool operator<=(const BigInt& rhs) const;
    bool operator<(const BigInt& rhs) const;

    void swap(const BigInt& rhs) const;
    bool isOdd();
    bool isZero();
};

