#ifndef RENDER_GAUGE_VECTORS_RGB
#define RENDER_GAUGE_VECTORS_RGB

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../visuals/_rendering/vector_rgb_rendering.hlsl"


namespace GaugeRendering
{
    /// Implementation of gauge field rendering as RGB based on the gauge vector components.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace RenderGaugeVectorsRGB
    {
        // Get the color at a given position based on the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_rgb_color(GaugeSymmetriesVectorPack state)
        {
            half4 color = half4(0, 0, 0, 0);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++)
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                color += sqrt(VectorRGBRendering::four_vector_components_as_color_channels_parity_aware(state[symmetry_index]));
            }
            return color;
        }

        // Get the color at a given position based on the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_rgb_color_at_position(GaugeLatticeBuffer target_lattice_buffer, half3 position)
        {
            half4 color = half4(0, 0, 0, 0); 
            GaugeSymmetriesVectorPack state;
            FieldInterpolations::get_gauge_state_in_position(position, target_lattice_buffer, state);
            return get_gauge_vectors_rgb_color(state);
        }

        // Get the color at a given position based on the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_scaled_rgb_color(GaugeSymmetriesVectorPack state)
        {
            half4 color = half4(0, 0, 0, 0);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++)
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                half4 four_vector = state[symmetry_index];
                half norm = CommonMath::harmonic_mean(length(four_vector), 1);
                half4 albedo = sqrt(VectorRGBRendering::four_vector_components_as_color_channels_parity_aware(four_vector));
                color += norm * CommonMath::adjust_saturation(albedo, norm);
            }
            return color;
        }

        // Get the color at a given position based on the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_scaled_rgb_color_at_position(GaugeLatticeBuffer target_lattice_buffer, half3 position)
        {
            half4 color = half4(0, 0, 0, 0);
            GaugeSymmetriesVectorPack state;
            FieldInterpolations::get_gauge_state_in_position(position, target_lattice_buffer, state);
            return get_gauge_vectors_scaled_rgb_color(state);
        }
    }
}

#endif
