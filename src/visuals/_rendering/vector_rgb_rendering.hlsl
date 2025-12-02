#ifndef VECTOR_RGB_RENDERING
#define VECTOR_RGB_RENDERING


namespace VectorRGBRendering
{
    half4 four_vector_components_as_color_channels(half4 four_vector)
    {
        return half4(four_vector.yzw, four_vector.x);
    }
    
    half4 four_vector_components_as_color_channels_parity_aware(half4 four_vector)
    {
        const half3 positive_components = max(four_vector.yzw, 0);
        const half3 negative_components = max(-four_vector.yzw, 0);
        return half4(
            positive_components[0] + 0.5 * (negative_components[1] + negative_components[2]),
            positive_components[1] + 0.5 * (negative_components[0] + negative_components[2]),
            positive_components[2] + 0.5 * (negative_components[0] + negative_components[1]),
            four_vector.x
        );
    }
}

#endif
