#ifndef COMMON_MATH
#define COMMON_MATH

/// This namespace implements functions used to perform simple common mathematical operations.
namespace CommonMath
{
    const half PI = 3.14159265358979323846;

    half harmonic_mean(half a, half b)
    {
        return a * b / (a + b);
    }

    half2 harmonic_mean(half2 a, half2 b)
    {
        return a * b / (a + b);
    }

    half3 harmonic_mean(half3 a, half3 b)
    {
        return a * b / (a + b);
    }

    half4 harmonic_mean(half4 a, half4 b)
    {
        return a * b / (a + b);
    }

    half sigmoid(half a)
    {
        return 1 / (1 + exp(-a));
    }

    half2 sigmoid(half2 a)
    {
        return 1 / (1 + exp(-a));
    }

    half3 sigmoid(half3 a)
    {
        return 1 / (1 + exp(-a));
    }

    half4 sigmoid(half4 a)
    {
        return 1 / (1 + exp(-a));
    }

    half3 cartesian_to_spherical(half3 cartesian)
    {
        half r = length(cartesian);
        half theta = length(cartesian.xy) ? atan2(cartesian.y, cartesian.x) : 0;
        half phi = r ? acos(cartesian.z / r) : 0;
        return half3(r, theta, phi);
    }

    half3 spherical_to_cartesian(half3 spherical)
    {
        half r = spherical.x;
        half theta = spherical.y;
        half phi = spherical.z;
        return half3(r * sin(phi) * cos(theta), r * sin(phi) * sin(theta), r * cos(phi));
    }

    half gaussian(half x, half stddev)
    {
        return exp(-0.5 * pow(x / stddev, 2)) / (stddev * sqrt(2 * PI));
    }

    half gaussian(half2 x, half stddev)
    {
        return gaussian(length(x), stddev);
    }

    half gaussian(half3 x, half stddev)
    {
        return gaussian(length(x), stddev);
    }

    half gaussian(half4 x, half stddev)
    {
        return gaussian(length(x), stddev);
    }

    half3 hsv2rgb(half3 hsv)
    {
        half h = hsv.x;
        half s = hsv.y;
        half v = hsv.z;
        half3 k = half3(1.0, 2.0 / 3.0, 1.0 / 3.0);
        half3 p = abs(frac(h + k) * 6.0 - 3.0);
        half3 rgb = lerp(k.xxx, saturate(p - k.xxx), 1.0);
        rgb = lerp(half3(1.0, 1.0, 1.0), rgb, s);
        return v * rgb;
    }
    
    half3 adjust_saturation(half3 color, half saturation)
    {
        half luma = dot(color, half3(0.2126, 0.7152, 0.0722));
        return lerp(luma.xxx, color, saturation);
    }

    half4 adjust_saturation(half4 color, half saturation)
    {
        half luma = dot(color.rgb, half3(0.2126, 0.7152, 0.0722));
        return half4(lerp(luma.xxx, color.rgb, saturation), color.a);
    }

    void interpolate_2d(half2 fraction, half values[4], out half result)
    {
        half v00 = values[0];
        half v01 = values[1];
        half v10 = values[2];
        half v11 = values[3];
        half v0 = lerp(v00, v01, fraction.y);
        half v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(half2 fraction, half2 values[4], out half2 result)
    {
        half2 v00 = values[0];
        half2 v01 = values[1];
        half2 v10 = values[2];
        half2 v11 = values[3];
        half2 v0 = lerp(v00, v01, fraction.y);
        half2 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(half2 fraction, half3 values[4], out half3 result)
    {
        half3 v00 = values[0];
        half3 v01 = values[1];
        half3 v10 = values[2];
        half3 v11 = values[3];
        half3 v0 = lerp(v00, v01, fraction.y);
        half3 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_2d(half2 fraction, half4 values[4], out half4 result)
    {
        half4 v00 = values[0];
        half4 v01 = values[1];
        half4 v10 = values[2];
        half4 v11 = values[3];
        half4 v0 = lerp(v00, v01, fraction.y);
        half4 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(half3 fraction, half values[8], out half result)
    {
        half v000 = values[0];
        half v001 = values[1];
        half v010 = values[2];
        half v011 = values[3];
        half v100 = values[4];
        half v101 = values[5];
        half v110 = values[6];
        half v111 = values[7];
        half v00 = lerp(v000, v001, fraction.z);
        half v01 = lerp(v010, v011, fraction.z);
        half v10 = lerp(v100, v101, fraction.z);
        half v11 = lerp(v110, v111, fraction.z);
        half v0 = lerp(v00, v01, fraction.y);
        half v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(half3 fraction, half2 values[8], out half2 result)
    {
        half2 v000 = values[0];
        half2 v001 = values[1];
        half2 v010 = values[2];
        half2 v011 = values[3];
        half2 v100 = values[4];
        half2 v101 = values[5];
        half2 v110 = values[6];
        half2 v111 = values[7];
        half2 v00 = lerp(v000, v001, fraction.z);
        half2 v01 = lerp(v010, v011, fraction.z);
        half2 v10 = lerp(v100, v101, fraction.z);
        half2 v11 = lerp(v110, v111, fraction.z);
        half2 v0 = lerp(v00, v01, fraction.y);
        half2 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(half3 fraction, half3 values[8], out half3 result)
    {
        half3 v000 = values[0];
        half3 v001 = values[1];
        half3 v010 = values[2];
        half3 v011 = values[3];
        half3 v100 = values[4];
        half3 v101 = values[5];
        half3 v110 = values[6];
        half3 v111 = values[7];
        half3 v00 = lerp(v000, v001, fraction.z);
        half3 v01 = lerp(v010, v011, fraction.z);
        half3 v10 = lerp(v100, v101, fraction.z);
        half3 v11 = lerp(v110, v111, fraction.z);
        half3 v0 = lerp(v00, v01, fraction.y);
        half3 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    void interpolate_3d(half3 fraction, half4 values[8], out half4 result)
    {
        half4 v000 = values[0];
        half4 v001 = values[1];
        half4 v010 = values[2];
        half4 v011 = values[3];
        half4 v100 = values[4];
        half4 v101 = values[5];
        half4 v110 = values[6];
        half4 v111 = values[7];
        half4 v00 = lerp(v000, v001, fraction.z);
        half4 v01 = lerp(v010, v011, fraction.z);
        half4 v10 = lerp(v100, v101, fraction.z);
        half4 v11 = lerp(v110, v111, fraction.z);
        half4 v0 = lerp(v00, v01, fraction.y);
        half4 v1 = lerp(v10, v11, fraction.y);
        result = lerp(v0, v1, fraction.x);
    }

    half integer_pow(half x, uint exponent)
    {
        if (exponent == 0) return 1.0;
        if (exponent == 1) return x;
        const half x2 = x * x;
        if (exponent == 2) return x2;
        const half x3 = x2 * x;
        if (exponent == 3) return x3;
        const half x4 = x2 * x2;
        if (exponent == 4) return x4;
        const half x5 = x3 * x2;
        if (exponent == 5) return x5;
        const half x6 = x3 * x3;
        if (exponent == 6) return x6;
        const half x7 = x3 * x4;
        if (exponent == 7) return x7;
        const half x8 = x4 * x4;
        if (exponent == 8) return x8;
        const half x9 = x4 * x5;
        if (exponent == 9) return x9;
        const half x10 = x5 * x5;
        if (exponent == 10) return x10;
        return pow(x, exponent);
    }

    half2 integer_pow(half2 x, uint exponent)
    {
        if (exponent == 0) return 1.0;
        if (exponent == 1) return x;
        const half2 x2 = x * x;
        if (exponent == 2) return x2;
        const half2 x3 = x2 * x;
        if (exponent == 3) return x3;
        const half2 x4 = x2 * x2;
        if (exponent == 4) return x4;
        const half2 x5 = x3 * x2;
        if (exponent == 5) return x5;
        const half2 x6 = x3 * x3;
        if (exponent == 6) return x6;
        const half2 x7 = x3 * x4;
        if (exponent == 7) return x7;
        const half2 x8 = x4 * x4;
        if (exponent == 8) return x8;
        const half2 x9 = x4 * x5;
        if (exponent == 9) return x9;
        const half2 x10 = x5 * x5;
        if (exponent == 10) return x10;
        return pow(x, exponent);
    }

    half3 integer_pow(half3 x, uint exponent)
    {
        if (exponent == 0) return 1.0;
        if (exponent == 1) return x;
        const half3 x2 = x * x;
        if (exponent == 2) return x2;
        const half3 x3 = x2 * x;
        if (exponent == 3) return x3;
        const half3 x4 = x2 * x2;
        if (exponent == 4) return x4;
        const half3 x5 = x3 * x2;
        if (exponent == 5) return x5;
        const half3 x6 = x3 * x3;
        if (exponent == 6) return x6;
        const half3 x7 = x3 * x4;
        if (exponent == 7) return x7;
        const half3 x8 = x4 * x4;
        if (exponent == 8) return x8;
        const half3 x9 = x4 * x5;
        if (exponent == 9) return x9;
        const half3 x10 = x5 * x5;
        if (exponent == 10) return x10;
        return pow(x, exponent);
    }

    half4 integer_pow(half4 x, uint exponent)
    {
        if (exponent == 0) return 1.0;
        if (exponent == 1) return x;
        const half4 x2 = x * x;
        if (exponent == 2) return x2;
        const half4 x3 = x2 * x;
        if (exponent == 3) return x3;
        const half4 x4 = x2 * x2;
        if (exponent == 4) return x4;
        const half4 x5 = x3 * x2;
        if (exponent == 5) return x5;
        const half4 x6 = x3 * x3;
        if (exponent == 6) return x6;
        const half4 x7 = x3 * x4;
        if (exponent == 7) return x7;
        const half4 x8 = x4 * x4;
        if (exponent == 8) return x8;
        const half4 x9 = x4 * x5;
        if (exponent == 9) return x9;
        const half4 x10 = x5 * x5;
        if (exponent == 10) return x10;
        return pow(x, exponent);
    }
}

#endif
