#ifndef RENDER_GAUGE_VECTORS_DIALS
#define RENDER_GAUGE_VECTORS_DIALS

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../_rendering/vector_dial_rendering.hlsl"


namespace GaugeRendering
{
    /// Implementation of gauge field rendering by mapping vectors onto dials.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace RenderGaugeVectorsDials
    {
        // Get the color at a given position to render gauge vectors as dials.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_dial_color_at_position_xy(GaugeLatticeBuffer target_lattice_buffer, half3 position, half granularity, half length_scale)
        {
            half4 color = half4(0, 0, 0, 0);
            half3 rounded_position;
            half2 offset_coefficient;
            VectorDialRendering::calculate_position_offset_variables_xy(position, granularity, rounded_position, offset_coefficient);
            uint buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(rounded_position);
            GaugeSymmetriesVectorPack state = target_lattice_buffer[buffer_index];
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++) 
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                half4 field_vector = state[symmetry_index];
                field_vector[3] = 0;
                half3 symmetry_color = CommonMath::hsv2rgb(half3(symmetry_index / 12.0f, 0.5f, 1));
                color += half4(symmetry_color, 1) * VectorDialRendering::get_vector_dial_color_at_position_xy(field_vector, length_scale, offset_coefficient);
            }
            return color;
        }
    }
}

#endif
