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
        for (uint i = 0; i < FERMION_FIELDS_COUNT; i++) color += compute_fermion_field_norm_color(position, i, buffer);
        saturate(color);
        return color;
    }

    // This function computes the color of a fermion field at a given position and field index with
    // the color's hue directly representing the state's phase and brightness directly proportional to the
    // field's norm, tinted with the specified color in the field's properties.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_field_phase_color(float3 position, uint field_index, FermionLatticeBuffer buffer)
    {
        if (!SimulationDataOps::is_fermion_field_active(field_index)) return float4(0, 0, 0, 0);
        FermionFieldProperties field_properties = fermion_field_properties[field_index];
        float state_norm;
        float2 state_phase;
        SimulationToScreenSpace::get_fermion_field_dirac_norm(position, field_index, buffer, state_norm);
        SimulationToScreenSpace::get_fermion_field_phase(position, field_index, buffer, state_phase);
        float phase = atan2(state_phase.y, state_phase.x);
        float hue = (phase + 3.14159265) / (2.0 * 3.14159265);
        float3 k = float3(1.0, 2.0 / 3.0, 1.0 / 3.0);
        float3 p = abs(frac(hue + k) * 6.0 - 3.0);
        float3 rgb = lerp(k.xxx, saturate(p - k.xxx), 1.0);
        float norm_factor = 1 - exp(-abs(state_norm));
        float4 color = float4(rgb, 1.0) * simulation_brightness * norm_factor;
        saturate(color);
        return color;
    }

    // This function computes the combined color of all fermion fields at a given position based on
    // their phases and norms, tinted with the specified color in the field's properties.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_fields_phase_color(float3 position, FermionLatticeBuffer buffer)
    {
        float4 color = float4(0, 0, 0, 0);
        for (uint i = 0; i < FERMION_FIELDS_COUNT; i++) color += compute_fermion_field_phase_color(position, i, buffer);
        saturate(color);
        return color;
    }

    // This function computes the color associated with a dial located at a given position indicating the spin state of a
    // fermion field with a provided field index - tinted with the field's configured color.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_field_spin_dial_color(float3 position, uint field_index, FermionLatticeBuffer buffer)
    {
        if (!SimulationDataOps::is_fermion_field_active(field_index)) return float4(0, 0, 0, 0);
        float3 rounded_position = round(position);
        float3 delta_position = position - rounded_position;
        float offset = length(delta_position);
        if (offset == 0) return float4(0, 0, 0, 0);
        FermionFieldProperties field_properties = fermion_field_properties[field_index];
        uint buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(rounded_position, field_index);
        FermionFieldState fermion_state = buffer[buffer_index];
        float3 fermion_spin_state = DiracFormalism::obtain_spin_state(fermion_state);
        float spin_state_norm = length(fermion_spin_state);
        if (spin_state_norm < 0.01) return float4(0, 0, 0, 0);
        float cross_product = length(cross(fermion_spin_state, delta_position)) / (spin_state_norm * spin_state_norm);
        return (float4(1, 1, 1, 1) + field_properties.color) * exp(-cross_product * cross_product) * sqrt(max(0.25 - offset * offset, 0));
    }

    // This function computes the combined color of all fermion fields at a given position associated with a dial located
    // at a given position indicating the spin state of the fermion fields - tinted with the fields' configured color.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float4 compute_fermion_fields_spin_dial_color(float3 position, FermionLatticeBuffer buffer)
    {
        float4 color = float4(0, 0, 0, 0);
        for (uint i = 0; i < FERMION_FIELDS_COUNT; i++) color += compute_fermion_field_spin_dial_color(position, i, buffer);
        saturate(color);
        return color;
    }
}

#endif
