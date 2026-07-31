#ifndef SCALAR_RENDERING
#define SCALAR_RENDERING

#include "../../core/math/common_math.hlsl"


/// Implementation of some scalar rendering utilities.
namespace ScalarRendering
{
    half4 interpolate_color_segment(half t, half4 a, half4 b, half inv_segment_size, half segment_start)
    {
        const half local_t = saturate((t - segment_start) * inv_segment_size);
        return lerp(a, b, local_t);
    }

    half4 interpolate_color_5(half t, half4 c0, half4 c1, half4 c2, half4 c3, half4 c4)
    {
        if (t <= 0) return c0;
        if (t >= 1) return c4;
        const half segment_size = (half)0.25;
        const half inv_segment_size = (half)4;
        if (t < segment_size) return interpolate_color_segment(t, c0, c1, inv_segment_size, 0);
        if (t < 2 * segment_size) return interpolate_color_segment(t, c1, c2, inv_segment_size, segment_size);
        if (t < 3 * segment_size) return interpolate_color_segment(t, c2, c3, inv_segment_size, 2 * segment_size);
        return interpolate_color_segment(t, c3, c4, inv_segment_size, 3 * segment_size);
    }

    half4 interpolate_color_7(half t, half4 c0, half4 c1, half4 c2, half4 c3, half4 c4, half4 c5, half4 c6)
    {
        if (t <= 0) return c0;
        if (t >= 1) return c6;
        const half segment_size = (half)(1.0 / 6.0);
        const half inv_segment_size = (half)6;
        if (t < segment_size) return interpolate_color_segment(t, c0, c1, inv_segment_size, 0);
        if (t < 2 * segment_size) return interpolate_color_segment(t, c1, c2, inv_segment_size, segment_size);
        if (t < 3 * segment_size) return interpolate_color_segment(t, c2, c3, inv_segment_size, 2 * segment_size);
        if (t < 4 * segment_size) return interpolate_color_segment(t, c3, c4, inv_segment_size, 3 * segment_size);
        if (t < 5 * segment_size) return interpolate_color_segment(t, c4, c5, inv_segment_size, 4 * segment_size);
        return interpolate_color_segment(t, c5, c6, inv_segment_size, 5 * segment_size);
    }

    half4 interpolate_color_8(half t, half4 c0, half4 c1, half4 c2, half4 c3, half4 c4, half4 c5, half4 c6, half4 c7)
    {
        if (t <= 0) return c0;
        if (t >= 1) return c7;
        const half segment_size = (half)(1.0 / 7.0);
        const half inv_segment_size = (half)7;
        if (t < segment_size) return interpolate_color_segment(t, c0, c1, inv_segment_size, 0);
        if (t < 2 * segment_size) return interpolate_color_segment(t, c1, c2, inv_segment_size, segment_size);
        if (t < 3 * segment_size) return interpolate_color_segment(t, c2, c3, inv_segment_size, 2 * segment_size);
        if (t < 4 * segment_size) return interpolate_color_segment(t, c3, c4, inv_segment_size, 3 * segment_size);
        if (t < 5 * segment_size) return interpolate_color_segment(t, c4, c5, inv_segment_size, 4 * segment_size);
        if (t < 6 * segment_size) return interpolate_color_segment(t, c5, c6, inv_segment_size, 5 * segment_size);
        return interpolate_color_segment(t, c6, c7, inv_segment_size, 6 * segment_size);
    }

    // Returns a color that represents a scalar in a temperature-like color scale (black - dark-blue - blue - white - red).
    half4 scalar_temperature_color(half scalar, half scale)
    {
        if (scale == 0) return half4(0, 0, 0, 0);
        const half dimensionless = scalar / scale;
        const half normalized = saturate(CommonMath::harmonic_mean(abs(dimensionless), 1));
        const half4 c0 = half4(0, 0, 0, 1);
        const half4 c1 = half4(0, 0, 0.2, 1);
        const half4 c2 = half4(0, 0, 1, 1);
        const half4 c3 = half4(1, 0.7, 0.5, 1);
        const half4 c4 = half4(1, 0, 0, 1);
        return interpolate_color_5(normalized, c0, c1, c2, c3, c4);
    }

    // Returns a color that represents a scalar in a black-body-like color scale (black - dark-red - red - orange - yellow - white - light-blue).
    half4 scalar_black_body_color(half scalar, half scale)
    {
        if (scale == 0) return half4(0, 0, 0, 0);
        const half dimensionless = scalar / scale;
        const half normalized = saturate(CommonMath::harmonic_mean(abs(dimensionless), 1));
        const half4 c0 = half4(0, 0, 0, 1);
        const half4 c1 = half4(0.2, 0, 0, 1);
        const half4 c2 = half4(1, 0, 0, 1);
        const half4 c3 = half4(1, 0.5, 0, 1);
        const half4 c4 = half4(1, 1, 0, 1);
        const half4 c5 = half4(1, 1, 1, 1);
        const half4 c6 = half4(0.6, 0.8, 1, 1);
        return interpolate_color_7(normalized, c0, c1, c2, c3, c4, c5, c6);
    }

    // Returns a color that represents a scalar in a rainbow-like color scale (black - dark-blue - blue - cyan - green - yellow - red - white).
    half4 scalar_rainbow_heat_color(half scalar, half scale)
    {
        if (scale == 0) return half4(0, 0, 0, 0);
        const half dimensionless = scalar / scale;
        const half normalized = saturate(CommonMath::harmonic_mean(abs(dimensionless), 1));
        const half4 c0 = half4(0, 0, 0, 1);
        const half4 c1 = half4(0, 0, 0.2, 1);
        const half4 c2 = half4(0, 0, 1, 1);
        const half4 c3 = half4(0, 1, 1, 1);
        const half4 c4 = half4(0, 1, 0, 1);
        const half4 c5 = half4(1, 1, 0, 1);
        const half4 c6 = half4(1, 0, 0, 1);
        const half4 c7 = half4(1, 1, 1, 1);
        return interpolate_color_8(normalized, c0, c1, c2, c3, c4, c5, c6, c7);
    }

    // Returns a color that represents a scalar in a rainbow-like color scale (black - purple - cyan - green - orange).
    half4 scalar_plasma_color(half scalar, half scale)
    {
        if (scale == 0) return half4(0, 0, 0, 0);
        const half dimensionless = scalar / scale;
        const half normalized = saturate(CommonMath::harmonic_mean(abs(dimensionless), 1));
        const half4 c0 = half4(0, 0, 0, 1);
        const half4 c1 = half4(0.31, 0.13, 1, 1);
        const half4 c2 = half4(0.082, 0.83, 1, 1);
        const half4 c3 = half4(0.31, 0.94, 0.67, 1);
        const half4 c4 = half4(0.72, 0.23, 0.06, 1);
        return interpolate_color_5(normalized, c0, c1, c2, c3, c4);
    }
}

#endif
