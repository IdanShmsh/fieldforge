#ifndef RENDER_GAUGE_VECTORS_RGB_CONTOURS
#define RENDER_GAUGE_VECTORS_RGB_CONTOURS

#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/analysis/field_interpolations.hlsl"
#include "../../visuals/_rendering/vector_rgb_rendering.hlsl"


namespace GaugeRendering
{
    /// Implementation of gauge field rendering as RGB based on the contours of the gauge vector components.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace RenderGaugeVectorsRGBContours
    {
        // Get the color at a given position based on the contours of the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
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
                const half norm = length(four_vector);
                const half4 periodic = CommonMath::integer_pow(abs(frac(channels * granularity - 0.5) * 2 - 1), definition);
                color += sqrt(norm) * periodic;
            }
            return color;
        }
        
        // Get the color at a given position based on the contours of the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_vectors_norm_contours_color_at_position(GaugeLatticeBuffer target_lattice_buffer, half3 position, half granularity, uint definition)
        {
            half4 color = half4(0, 0, 0, 0);  
            GaugeSymmetriesVectorPack state;
            FieldInterpolations::get_gauge_state_in_position(position, target_lattice_buffer, state);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++) 
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                const half4 four_vector = state[symmetry_index];
                const half norm = length(four_vector);
                const half4 periodic = CommonMath::integer_pow(abs(frac(norm * granularity - 0.5) * 2 - 1), definition);
                color += sqrt(norm) * periodic;
            }
            return color;
        }

        // Get the color at a given position based on the contours of the gauge vector components mapped to individual colors.
        // • Reads directly from the simulation's lattice buffers
        half4 get_gauge_strength_norm_contours_color_at_position(GaugeLatticeBuffer electric_lattice_buffer, GaugeLatticeBuffer magnetic_lattice_buffer, half3 position, half granularity, uint definition)
        {
            half4 color = half4(0, 0, 0, 0);
            GaugeSymmetriesVectorPack electric_state, magnetic_state;
            FieldInterpolations::get_gauge_state_in_position(position, electric_lattice_buffer, electric_state);
            FieldInterpolations::get_gauge_state_in_position(position, magnetic_lattice_buffer, magnetic_state);
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++)
            {
                if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                const half4 electric_four_vector = electric_state[symmetry_index];
                const half4 magnetic_four_vector = magnetic_state[symmetry_index];
                const half strength = sqrt(dot(electric_four_vector, electric_four_vector) + dot(magnetic_four_vector, magnetic_four_vector));
                const half4 periodic = CommonMath::integer_pow(abs(frac(strength * granularity - 0.5) * 2 - 1), definition);
                color += sqrt(strength) * periodic;
            }
            return color;
        }
    }
}

#endif
