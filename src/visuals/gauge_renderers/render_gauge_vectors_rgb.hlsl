#ifndef RENDER_GAUGE_VECTORS_RGB
#define RENDER_GAUGE_VECTORS_RGB

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../visuals/_rendering/vector_rgb_rendering.hlsl"


namespace GaugeRendering
{
    namespace RenderGaugeVectorsRGB
    {
        half4 get_gauge_vectors_rgb_color_at_position(GaugeLatticeBuffer target_lattice_buffer, half3 position)
        {
            half4 color = half4(0, 0, 0, 0); 
            GaugeSymmetriesVectorPack state;
            FieldInterpolations::get_gauge_state_in_position(position, target_lattice_buffer, state);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++) 
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                color += sqrt(VectorRGBRendering::four_vector_components_as_color_channels_parity_aware(state[symmetry_index]));
            }
            return color;
        }
    }
}

#endif
