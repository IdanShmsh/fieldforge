#ifndef RENDER_GAUGE_VECTORS_RGB_CONTOURS
#define RENDER_GAUGE_VECTORS_RGB_CONTOURS

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../visuals/_rendering/vector_rgb_rendering.hlsl"


namespace GaugeRendering
{
    namespace RenderGaugeVectorsRGBContours
    {
        half4 get_gauge_vectors_rgb_contours_color_at_position(GaugeLatticeBuffer target_lattice_buffer, half3 position, half granularity, uint definition)
        {
            half4 color = half4(0, 0, 0, 0);  
            GaugeSymmetriesVectorPack state;
            FieldInterpolations::get_gauge_state_in_position(position, target_lattice_buffer, state);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++) 
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                const half4 four_vector = state[symmetry_index];
                const half4 channels = sqrt(VectorRGBRendering::four_vector_components_as_color_channels_parity_aware(four_vector));
                const half4 periodic = CommonMath::integer_pow(abs(frac(channels * granularity - 0.5) * 2 - 1), definition);
                color += sqrt(length(four_vector)) * periodic;
            }
            return color;
        }
    }
}

#endif
