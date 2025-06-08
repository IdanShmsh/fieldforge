#ifndef FERMION_FIELD_STATE_DIFFERENTIALS
#define FERMION_FIELD_STATE_DIFFERENTIALS

#include "../ops/simulation_data_ops.hlsl"
#include "../simulation_globals.hlsl"
#include "../math/fermion_field_state_math.hlsl"

typedef FermionFieldState FermionFieldSpatialGradient[3];
typedef FermionFieldState FermionFieldSpacetimeGradient[4];

/// This namespace implements functions used to compute derivatives of fermion fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FermionFieldStateDifferentials
{
    // Take the derivative of a fermion field with a specified field-index, at a specified simulation location, along the temporal axis.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void temporal_derivative(float3 position, uint fermion_field_index, out FermionFieldState field_derivative)
    {
        uint lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, fermion_field_index);
        FermionFieldState prev_fermion_field_state = prev_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldState crnt_fermion_field_state = crnt_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldStateMath::sub(crnt_fermion_field_state, prev_fermion_field_state, field_derivative);
        FermionFieldStateMath::rscl(field_derivative, 1 / simulation_temporal_unit, field_derivative);
    }

    // Take the derivative of a fermion field with a specified field-index, at a specified simulation location, along a specified spatial axis,
    // in a specified fermion lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, uint fermion_field_index, FermionLatticeBuffer fermion_lattice_buffer, out FermionFieldState field_derivative)
    {
        FermionFieldStateOps::empty(field_derivative);
        if (axis > SPATIAL_DIMENSIONALITY - 1) return;
        float3 offset = float3(0, 0, 0);
        offset[axis] = 1;
        uint lattice_buffer_index;
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position - offset, fermion_field_index);
        FermionFieldState neighboring_fermion_state1 = fermion_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, fermion_field_index);
        FermionFieldState neighboring_fermion_state2 = fermion_lattice_buffer[lattice_buffer_index];
        FermionFieldStateMath::sub(neighboring_fermion_state2, neighboring_fermion_state1, field_derivative);
        FermionFieldStateMath::rscl(field_derivative, 0.5 / simulation_spatial_unit, field_derivative);
    }

    // Take the derivative of a fermion field with a specified field-index, at a specified simulation location, along a specified spatial axis,
    // in the current fermion lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, uint field_index, out FermionFieldState field_derivative)
    {
        spatial_derivative(axis, position, field_index, crnt_fermions_lattice_buffer, field_derivative);
    }

    // Take the gradient of a fermion field with a specified field-index, at a specified simulation location, along all spacetime axes.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_gradient(float3 position, uint fermion_field_index, out FermionFieldSpacetimeGradient field_gradient)
    {
        temporal_derivative(position, fermion_field_index, field_gradient[0]);
        spatial_derivative(0, position, fermion_field_index, field_gradient[1]);
        spatial_derivative(1, position, fermion_field_index, field_gradient[2]);
        spatial_derivative(2, position, fermion_field_index, field_gradient[3]);
    }

    // Take the gradient of a fermion field with a specified field-index, at a specified simulation location, along all spatial axes.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_gradient(float3 position, uint fermion_field_index, out FermionFieldSpatialGradient field_gradient)
    {
        spatial_derivative(0, position, fermion_field_index, field_gradient[0]);
        spatial_derivative(1, position, fermion_field_index, field_gradient[1]);
        spatial_derivative(2, position, fermion_field_index, field_gradient[2]);
    }
}

#endif
