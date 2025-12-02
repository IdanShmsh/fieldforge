#ifndef VECTOR_DIAL_RENDERING
#define VECTOR_DIAL_RENDERING

#include "../../core/analysis/field_interpolations.hlsl"


namespace VectorDialRendering
{
    half4 get_vector_dial_color_at_position_xy(half4 field_vector, half length_scale, half2 offset_coefficient)
    {
        field_vector[0] = 0;
        const half field_vector_length = length(field_vector);
        if (field_vector_length == 0) return half4(0, 0, 0, 0);
        const half4 normalized_field_vector = field_vector / field_vector_length;
        const half4 relative_to_length_scale = field_vector_length / length_scale;
        const half limited_length = CommonMath::harmonic_mean(relative_to_length_scale, 1);
        const half dot_product = dot(normalized_field_vector.yz, offset_coefficient);
        const half parallel_offset_coefficient = (3 * dot_product) / (2 * limited_length) - 0.5;
        const half cross_product = length(cross(normalized_field_vector.yzw, half3(offset_coefficient, 0)));
        const half perpendicular_offset_coefficient = cross_product / 0.1;
        const half dial_color_falloff = sqrt(max(0, 1 - CommonMath::integer_pow(parallel_offset_coefficient, 4) - CommonMath::integer_pow(perpendicular_offset_coefficient, 2)));
        const half circular_falloff = sqrt(max(0, 1 - dot(offset_coefficient, offset_coefficient)));
        const half total_color_factor = dial_color_falloff * circular_falloff;
        return total_color_factor * sqrt(limited_length);
    }

    void calculate_position_offset_variables_xy(half3 position, half granularity, out half3 rounded_position, out half2 offset_coefficient)
    {
        rounded_position = round(position / granularity) * granularity;
        offset_coefficient = 2 * (position.xy - rounded_position.xy) / granularity;
    }
}

#endif
