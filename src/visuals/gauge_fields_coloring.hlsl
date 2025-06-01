#ifndef GAUGE_FIELD_COLORING
#define GAUGE_FIELD_COLORING

#include "simulation_to_screen_space.hlsl"

/// This namespace implements functions used to compute the color of gauge fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace GaugeFieldColoring
{
    // This function computes the color associated with a gauge potential at a given position and symmetry
    // index. The color represents the oriented vector potential of the gauge field.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_gauge_potential_color(float3 position, uint symmetry_index, GaugeLatticeBuffer buffer)
    {
        if (!SimulationDataOps::is_gauge_field_active(symmetry_index)) return float4(0, 0, 0, 0);
        float4 field_potential;
        SimulationToScreenSpace::get_gauge_field_component(position, symmetry_index, buffer, field_potential);
        float ampliude = length(field_potential);
        if (ampliude == 0) return float4(0, 0, 0, 0);
        field_potential *= simulation_brightness * (1 - exp(-abs(ampliude))) / ampliude;
        return abs(float4(field_potential[1], field_potential[3], field_potential[2], field_potential[0]));
    }

    // This function computes the combined color of all gauge potentials at a given position.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_gauge_potentials_color(float3 position, GaugeLatticeBuffer buffer)
    {
        float4 color = float4(0, 0, 0, 0);
        for (uint a = 0; a < 12; a++) color += compute_gauge_potential_color(position, a, buffer);
        saturate(color);
        return color;
    }

    // This function computes the color associated with a dial pointing along the spacial direction of the gauge potential associated
    // with a given symmetry index at a given position.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_gauge_potential_vector_dial_color(float3 position, uint symmetry_index, GaugeLatticeBuffer buffer)
    {
        if (!SimulationDataOps::is_gauge_field_active(symmetry_index)) return float4(0, 0, 0, 0);
        float3 rounded_position = round(position);
        float3 delta_position = position - rounded_position;
        float offset = length(delta_position);
        if (offset == 0) return float4(0, 0, 0, 0);
        uint buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(rounded_position);
        float4 field_potential = buffer[buffer_index][symmetry_index];
        float field_potential_norm_sqrd = dot(field_potential, field_potential);
        if (field_potential_norm_sqrd < 0.000001) return float4(0, 0, 0, 0);
        float cross_product = length(cross(field_potential.yzw, delta_position)) / field_potential_norm_sqrd;
        return float4(1, 1, 1, 1) * exp(-cross_product * cross_product) * sqrt(max(0.25 - offset * offset, 0));
    }

    // This function computes the combined color of all gauge potentials at a given position, represented as vector dials.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_gauge_potentials_vector_dial_color(float3 position, GaugeLatticeBuffer buffer)
    {
        float4 color = float4(0, 0, 0, 0);
        for (uint a = 0; a < 12; a++) color += compute_gauge_potential_vector_dial_color(position, a, buffer);
        saturate(color);
        return color;
    }
}

#endif
