#ifndef FERMION_FIELD_STATE_STRUCTURE_OPS
#define FERMION_FIELD_STATE_STRUCTURE_OPS

#include "../structures/fermion_field_state.hlsl"

/// This namespace implements functions used to perform basic operations on the fermion field state data structure.
namespace FermionFieldStateOps
{
    // Empty (zero) a fermion field state
    void empty(out FermionFieldState empty_fermion_state)
    {
        empty_fermion_state[0] = float2(0, 0);
        empty_fermion_state[1] = float2(0, 0);
        empty_fermion_state[2] = float2(0, 0);
        empty_fermion_state[3] = float2(0, 0);
        empty_fermion_state[4] = float2(0, 0);
        empty_fermion_state[5] = float2(0, 0);
        empty_fermion_state[6] = float2(0, 0);
        empty_fermion_state[7] = float2(0, 0);
        empty_fermion_state[8] = float2(0, 0);
        empty_fermion_state[9] = float2(0, 0);
        empty_fermion_state[10] = float2(0, 0);
        empty_fermion_state[11] = float2(0, 0);
    }

    // Fill a fermion field state with a complex value
    void fill(float2 component_value, out FermionFieldState empty_fermion_state)
    {
        empty_fermion_state[0] = component_value;
        empty_fermion_state[1] = component_value;
        empty_fermion_state[2] = component_value;
        empty_fermion_state[3] = component_value;
        empty_fermion_state[4] = component_value;
        empty_fermion_state[5] = component_value;
        empty_fermion_state[6] = component_value;
        empty_fermion_state[7] = component_value;
        empty_fermion_state[8] = component_value;
        empty_fermion_state[9] = component_value;
        empty_fermion_state[10] = component_value;
        empty_fermion_state[11] = component_value;
    }

    // Duplicate a fermion field state
    void dup(in FermionFieldState fermion_state, out FermionFieldState duped_fermion_state)
    {
        duped_fermion_state[0] = fermion_state[0];
        duped_fermion_state[1] = fermion_state[1];
        duped_fermion_state[2] = fermion_state[2];
        duped_fermion_state[3] = fermion_state[3];
        duped_fermion_state[4] = fermion_state[4];
        duped_fermion_state[5] = fermion_state[5];
        duped_fermion_state[6] = fermion_state[6];
        duped_fermion_state[7] = fermion_state[7];
        duped_fermion_state[8] = fermion_state[8];
        duped_fermion_state[9] = fermion_state[9];
        duped_fermion_state[10] = fermion_state[10];
        duped_fermion_state[11] = fermion_state[11];
    }

    // Get a component's fermion state index in a for spinor and color indices
    uint get_state_component_index(uint spinor_index, uint color_index)
    {
        return 3 * spinor_index + color_index;
    }

    // Get the set of fermion state indices associated with four spinor components for a given color index
    uint4 get_spinor_component_indices_for_color_index(uint color_index)
    {
        return uint4(
            color_index,
            3 + color_index,
            6 + color_index,
            9 + color_index
        );
    }

    // Check if a fermion field state is zero
    bool is_zero(FermionFieldState fermion_state)
    {
        for (uint i = 0; i < 12; i++) if (any(fermion_state[i])) return false;
        return true;
    }

    // Check if a fermion field state is below a certain provided tolerance threshold
    bool is_zero(FermionFieldState fermion_state, float numerical_tolerance)
    {
        for (uint i = 0; i < 12; i++) if (any(abs(fermion_state[i]) > numerical_tolerance)) return false;
        return true;
    }

    // Get the weak partner field index for a given fermion field index
    uint weak_partner_field_index(uint fermion_field_index)
    {
        return fermion_field_index ^ 1;
    }
}

#endif
