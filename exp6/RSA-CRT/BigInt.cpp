#include <cstdio>
#include <iostream>
#include <cmath>
#include <string>
#include <cstring>
#include <vector>
#include <algorithm>
#include "BigInt.h"
using namespace std;
using Long = long long;
const double PI = acos(-1.0);

struct Complex {
    double x, y;
    Complex(double _x = 0.0, double _y = 0.0) {
        x = _x;
        y = _y;
    }
    Complex operator-(const Complex& b)const {
        return Complex(x - b.x, y - b.y);
    }
    Complex operator+(const Complex& b)const {
        return Complex(x + b.x, y + b.y);
    }
    Complex operator*(const Complex& b)const {
        return Complex(x * b.x - y * b.y, x * b.y + y * b.x);
    }
};

void change(Complex y[], int len) {
    int i, j, k;
    for (i = 1, j = len / 2; i < len - 1; i++) {
        if (i < j)    swap(y[i], y[j]);
        k = len / 2;
        while (j >= k) {
            j = j - k;
            k = k / 2;
        }
        if (j < k)    j += k;
    }
}

void fft(Complex y[], int len, int on) {
    change(y, len);
    for (int i = 1; i < len; i <<= 1) {
        Complex mi(cos(PI / i), sin(PI / i) * on);
        for (int j = 0; j < len; j += (i << 1)) {
            Complex w(1, 0);
            for (int k = 0; k < i; k++, w = w * mi) {
                Complex t1 = y[j + k];
                Complex t2 = w * y[j + k + i];
                y[j + k] = t1 + t2;
                y[j + k + i] = t1 - t2;
            }
        }
    }
    if (on == -1) {
        for (int i = 0; i < len; i++) {
            y[i].x /= len;
        }
    }
}


int BigInt::absComp(const BigInt& lhs, const BigInt& rhs)
{
    if (lhs.size() != rhs.size())
        return lhs.size() < rhs.size() ? -1 : 1;
    for (int i = lhs.size() - 1; i >= 0; --i)
        if (lhs[i] != rhs[i])
            return lhs[i] < rhs[i] ? -1 : 1;
    return 0;
}


void BigInt::trim() const
{
    while (val.size() && val.back() == 0)
        val.pop_back();
    if (val.empty())
        nega = false;
}

int BigInt::size() const { return val.size(); }
Long& BigInt::operator[](int index) const { return val[index]; }
Long& BigInt::back() const { return val.back(); }
BigInt::BigInt(int size, bool nega) : val(size), nega(nega) {}
BigInt::BigInt(const std::vector<Long>& val, bool nega) : val(val), nega(nega) {}


std::ostream& operator<<(std::ostream& os, const BigInt& n)
{
    if (n.size())
    {
        if (n.nega)
            putchar('-');
        for (int i = n.size() - 1; i >= 0; --i)
        {
            if (i == n.size() - 1)
                printf("%lld", n[i]);
            else
                printf("%0*lld", n.Exp, n[i]);
        }
    }
    else
        putchar('0');
    return os;
}

BigInt operator+(const BigInt& lhs, const BigInt& rhs)
{
    BigInt ret(lhs);
    return ret += rhs;
}

BigInt operator-(const BigInt& lhs, const BigInt& rhs)
{
    BigInt ret(lhs);
    return ret -= rhs;
}

BigInt::BigInt(Long x)
{
    if (x < 0)
        x = -x, nega = true;
    while (x >= Mod)
        val.push_back(x % Mod), x /= Mod;
    if (x)
        val.push_back(x);
}

BigInt::BigInt(const char* s)
{
    int bound = 0, pos;
    if (s[0] == '-')
        nega = true, bound = 1;
    Long cur = 0, pow = 1;
    for (pos = strlen(s) - 1; pos >= Exp + bound - 1; pos -= Exp, val.push_back(cur), cur = 0, pow = 1)
        for (int i = pos; i > pos - Exp; --i)
            cur += (s[i] - '0') * pow, pow *= 10;
    for (cur = 0, pow = 1; pos >= bound; --pos)
        cur += (s[pos] - '0') * pow, pow *= 10;
    if (cur)
        val.push_back(cur);
}

BigInt & BigInt::operator=(const char* s) {
    BigInt n(s);
    *this = n;
    return *this;
}

BigInt& BigInt::operator=(const Long x) {
    BigInt n(x);
    *this = n;
    return *this;
}

std::istream& operator>>(std::istream& is, BigInt& n) {
    string s;
    is >> s;
    n = (char*)s.data();
    return is;
}

BigInt& BigInt::operator+=(const BigInt& rhs)
{
    const int cap = std::max(size(), rhs.size()) + 1;
    val.resize(cap);
    int carry = 0;
    for (int i = 0; i < cap - 1; ++i)
    {
        val[i] = Value(val[i], nega) + Value(At(rhs, i), rhs.nega) + carry, carry = 0;
        if (val[i] >= Mod)
            val[i] -= Mod, carry = 1;
        else if (val[i] < 0)
            val[i] += Mod, carry = -1;
    }
    if ((val.back() = carry) == -1) //assert(val.back() == 1 or 0 or -1)
    {
        nega = true, val.pop_back();
        bool tailZero = true;
        for (int i = 0; i < cap - 1; ++i)
        {
            if (tailZero && val[i])
                val[i] = Mod - val[i], tailZero = false;
            else
                val[i] = Mod - 1 - val[i];
        }
    }
    trim();
    return *this;
}

BigInt operator-(const BigInt& rhs)
{
    BigInt ret(rhs);
    ret.nega ^= 1;
    return ret;
}

BigInt& BigInt::operator-=(const BigInt& rhs)
{
    rhs.nega ^= 1;
    *this += rhs;
    rhs.nega ^= 1;
    return *this;
}

BigInt operator*(const BigInt& lhs, const BigInt& rhs)
{
    int len = 1;
    BigInt ll = lhs, rr = rhs;
    ll.nega = lhs.nega ^ rhs.nega;
    while (len < 2 * lhs.size() || len < 2 * rhs.size())len <<= 1;
    ll.val.resize(len+1), rr.val.resize(len);
    Complex* x1 = new Complex[len];
    Complex* x2 = new Complex[len];
    for (int i = 0; i < len; i++) {
        Complex nx(ll[i], 0.0), ny(rr[i], 0.0);
        x1[i] = nx;
        x2[i] = ny;
    }
    fft(x1, len, 1);
    fft(x2, len, 1);
    for (int i = 0; i < len; i++)
        x1[i] = x1[i] * x2[i];
    fft(x1, len, -1);
    for (int i = 0; i < len; i++)
        ll[i] = int(x1[i].x + 0.5);
    for (int i = 0; i < len; i++) {     // restore in binary
        ll[i + 1] += ll[i] / BigInt::Mod;
        ll[i] %= BigInt::Mod;
        // if (i == len) len++;
    }
    ll.trim();
    delete[] x1;
    delete[] x2;
    return ll;
}

BigInt operator*(const BigInt& lhs, const Long& x) {
    BigInt ret = lhs;
    bool negat = (x < 0);
    Long xx = (negat) ? -x : x;
    ret.nega ^= negat;
    ret.val.push_back(0);
    ret.val.push_back(0);
    for (int i = 0; i < ret.size(); i++)
        ret[i] *= xx;
    for (int i = 0; i < ret.size(); i++) {
        ret[i + 1] += ret[i] / BigInt::Mod;
        ret[i] %= BigInt::Mod;
    }
    ret.trim();
    return ret;
}

BigInt& BigInt::operator*=(const BigInt& rhs) { return *this = *this * rhs; }

BigInt& BigInt::operator*=(const Long& x) { return *this = *this * x; }

BigInt operator/(const BigInt& lhs, const BigInt& rhs)
{
    static std::vector<BigInt> powTwo{ BigInt(1) };
    static std::vector<BigInt> estimate;
    estimate.clear();
    if (BigInt::absComp(lhs, rhs) < 0)
        return BigInt();
    BigInt cur = rhs;
    int cmp;
    while ((cmp = BigInt::absComp(cur, lhs)) < 0)
    {
        estimate.push_back(cur), cur += cur;
        powTwo.push_back(powTwo.back() + powTwo.back());
    }
    if (cmp == 0)
        return BigInt(powTwo.back().val, lhs.nega ^ rhs.nega);

    BigInt ret = powTwo[estimate.size() - 1];
    cur = estimate[estimate.size() - 1];
    for (int i = estimate.size() - 1; i >= 0 && cmp != 0; --i)
        if ((cmp = BigInt::absComp(cur + estimate[i], lhs)) <= 0)
            cur += estimate[i], ret += powTwo[i];
    ret.nega = lhs.nega ^ rhs.nega;
    return ret;
}

BigInt operator/(const BigInt& num, const Long& x) {
    bool negat = (x < 0);
    Long xx = (negat) ? -x : x;
    BigInt ret;
    Long k = 0;
    ret.val.resize(num.size());
    ret.nega = (num.nega ^ negat);
    for (int i = num.size() - 1; i >= 0; i--) {
        ret[i] = (k * BigInt::Mod + num[i]) / xx;
        k = (k * BigInt::Mod + num[i]) % xx;
    }
    ret.trim();
    return ret;
}

BigInt operator%(const BigInt& lhs, const BigInt& rhs) {
    static std::vector<BigInt> powTwo{ BigInt(1) };
    static std::vector<BigInt> estimate;
    estimate.clear();
    if (BigInt::absComp(lhs, rhs) < 0)
        return lhs;
    BigInt cur = rhs;
    int cmp;
    while ((cmp = BigInt::absComp(cur, lhs)) < 0)
    {
        estimate.push_back(cur), cur += cur;
        powTwo.push_back(powTwo.back() + powTwo.back());
    }
    if (cmp == 0)
        return BigInt();

    BigInt ret = powTwo[estimate.size() - 1];
    cur = estimate[estimate.size() - 1];
    for (int i = estimate.size() - 1; i >= 0 && cmp != 0; --i)
        if ((cmp = BigInt::absComp(cur + estimate[i], lhs)) <= 0)
            cur += estimate[i], ret += powTwo[i];
    // cout << lhs << ' ' << rhs << ' ' << cur <<'\n';
    if (lhs.nega == true) return (rhs + cur + lhs);
    else return lhs - cur;
}

bool BigInt::operator==(const BigInt& rhs) const
{
    return nega == rhs.nega && val == rhs.val;
}
bool BigInt::operator!=(const BigInt& rhs) const { return nega != rhs.nega || val != rhs.val; }
bool BigInt::operator>=(const BigInt& rhs) const { return !(*this < rhs); }
bool BigInt::operator>(const BigInt& rhs) const { return !(*this <= rhs); }
bool BigInt::operator<=(const BigInt& rhs) const
{
    if (nega && !rhs.nega)
        return true;
    if (!nega && rhs.nega)
        return false;
    int cmp = absComp(*this, rhs);
    return nega ? cmp >= 0 : cmp <= 0;
}
bool BigInt::operator<(const BigInt& rhs) const
{
    if (nega && !rhs.nega)
        return true;
    if (!nega && rhs.nega)
        return false;
    return (absComp(*this, rhs) < 0) ^ nega;
}
void BigInt::swap(const BigInt& rhs) const
{
    std::swap(val, rhs.val);
    std::swap(nega, rhs.nega);
}

bool BigInt::isOdd() {
    if (val.size())
        return val[0] & 1;
    return false;
}

bool BigInt::isZero() {
    if (!val.size() || (val.size()==1 && !val[0]))
        return true;
    return false;
}