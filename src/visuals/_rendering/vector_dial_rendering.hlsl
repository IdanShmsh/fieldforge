#ifndef VECTOR_DIAL_RENDERING
#define VECTOR_DIAL_RENDERING

#include "../../core/analysis/field_interpolations.hlsl"
#include "../../core/simulation_globals.hlsl"


namespace VectorDialRendering
{
    half4 get_vector_dial_color_at_position(half4 field_vector, half length_scale, half2 offset_coefficient)
    {
        field_vector[0] = 0;
        const half field_vector_length = length(field_vector);
        if (field_vector_length == 0) return half4(0, 0, 0, 0);
        half4 normalized_field_vector = field_vector / field_vector_length;
        const half limited_length = CommonMath::harmonic_mean(field_vector_length / length_scale, 1);
        const half cross_product = length(cross(normalized_field_vector.yzw, half3(offset_coefficient, 0)));
        const half dot_product = max(dot(normalized_field_vector.yz * limited_length, offset_coefficient), 0);
        const half orthogonal_color_factor = exp(-cross_product * cross_product / (0.001 * 0.001));
        const half parallel_color_factor = sqrt(max(0, 1 - pow((2 * dot_product - limited_length) / limited_length, 4)));
        const half circular_falloff = sqrt(max(0.25 - dot(offset_coefficient, offset_coefficient), 0));
        const half total_color_factor = orthogonal_color_factor * parallel_color_factor * circular_falloff;
        return total_color_factor * sqrt(field_vector_length);
    }

    void calculate_position_offset_variables(half3 position, half granularity, out half3 rounded_position, out half2 offset_coefficient)
    {
        rounded_position = round(position / granularity) * granularity;
        const half2 delta_position = (position.xy - rounded_position.xy) / granularity;
        const half2 cell_dimensions = _ScreenParams.xy / float2(simulation_width, simulation_height) * granularity;
        offset_coefficient = delta_position.xy / cell_dimensions;
    }
}

#endif
