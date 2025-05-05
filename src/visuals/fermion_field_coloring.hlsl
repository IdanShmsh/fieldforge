#ifndef FERMION_FIELD_COLORING
#define FERMION_FIELD_COLORING

#include "simulation_to_screen_space.hlsl"

/// This namespace implements functions used to compute the color of fermion fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FermionFieldColoring
{
    // This function computes the color of a fermion field at a given position and field index with
    // the brightness directly proportional to the field's norm, tinted with the specified color in the
    // field's properties.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_field_norm_color(float3 position, uint fieldIndex, FermionLatticeBuffer buffer)
    {
        if (!SimulationDataOps::is_fermion_field_active(fieldIndex)) return float4(0, 0, 0, 0);
        FermionFieldProperties field_properties = fermion_field_properties[fieldIndex];
        float state_norm = 0;
        SimulationToScreenSpace::get_fermion_field_norm(position, fieldIndex, buffer, state_norm);
        float coloring_factor = 1 - exp(-abs(state_norm));
        return field_properties.color * simulation_brightness * coloring_factor;
    }

    // This function computes the combined color of all fermion fields at a given position based on
    // their norms, tinted with the specified color in the field's properties.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_fields_norm_color(float3 position, FermionLatticeBuffer buffer)
    {
        float4 color = float4(0, 0, 0, 0);
        for (uint i = 0; i < 8; i++) color += compute_fermion_field_norm_color(position, i, buffer);
        saturate(color);
        return color;
    }
}

#endif
