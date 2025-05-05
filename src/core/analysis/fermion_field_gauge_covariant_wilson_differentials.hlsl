#ifndef FERMION_FIELD_GAUGE_COVARIANT_WILSON_DIFFERENTIALS
#define FERMION_FIELD_GAUGE_COVARIANT_WILSON_DIFFERENTIALS

#include "fermion_field_state_differentials.hlsl"
#include "../formalisms/wilson_formalism.hlsl"
#include "../ops/fermion_field_state_ops.hlsl"

/// This namespace implements functions used to compute the gauge covariant Wilson derivatives of fermion fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FermionFieldGaugeCovariantWilsonDifferentials
{
    // Take the gauge covariant derivative of a fermion field with a specified field-index, at a specified simulation location,
    // along the temporal axis.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void temporal_derivative(float3 position, uint field_index, out FermionFieldState derivative)
    {
        uint lattice_buffer_index;
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState prev_fermion_state = prev_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldState crnt_fermion_state = crnt_fermions_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index ^ 1);
        FermionFieldState prev_weak_partner_state = prev_fermions_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack gauge_potentials = prev_gauge_potentials_lattice_buffer[lattice_buffer_index];
        float3 coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(field_index);
        WilsonFormalism::backward_parallel_transport_fermion(
            prev_fermion_state,
            prev_weak_partner_state,
            gauge_potentials,
            0,
            coupling_constants,
            field_index % 2 == 0,
            prev_fermion_state);
        FermionFieldStateMath::sub(crnt_fermion_state, prev_fermion_state, derivative);
        FermionFieldStateMath::rscl(derivative, 1 / simulation_temporal_unit, derivative);
    }

    // Take the gauge covariant derivative of a fermion field with a specified field-index, at a specified simulation location,
    // along a specified spatial axis, in a specified fermion lattice buffer and a specified gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, uint field_index, FermionLatticeBuffer fermion_lattice_buffer, GaugeLatticeBuffer gauge_potentials_lattice_buffer, out FermionFieldState derivative)
    {
        FermionFieldStateOps::empty(derivative);
        if (axis > SPATIAL_DIMENSIONALITY - 1) return;
        float3 offset = float3(0, 0, 0);
        offset[axis] = 1;
        uint lattice_buffer_index;
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position - offset, field_index);
        FermionFieldState neighboring_fermion_state1 = fermion_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, field_index);
        FermionFieldState neighboring_fermion_state2 = fermion_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position - offset, field_index ^ 1);
        FermionFieldState neighboring_weak_partner_state1 = fermion_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, field_index ^ 1);
        FermionFieldState neighboring_weak_partner_state2 = fermion_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position - offset);
        GaugeSymmetriesVectorPack link_gauge_potentials1 = gauge_potentials_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack link_gauge_potentials2 = gauge_potentials_lattice_buffer[lattice_buffer_index];
        bool weakDoubletIndex = field_index % 2 == 0;
        float3 coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(field_index);
        WilsonFormalism::backward_parallel_transport_fermion(
            neighboring_fermion_state1,
            neighboring_weak_partner_state1,
            link_gauge_potentials1,
            axis,
            coupling_constants,
            weakDoubletIndex,
            neighboring_fermion_state1);
        WilsonFormalism::parallel_transport_fermion(
            neighboring_fermion_state2,
            neighboring_weak_partner_state2,
            link_gauge_potentials2,
            axis,
            coupling_constants,
            weakDoubletIndex,
            neighboring_fermion_state2);
        FermionFieldState s;
        FermionFieldStateMath::sub(neighboring_fermion_state2, neighboring_fermion_state1, s);
        FermionFieldStateMath::rscl(s, 0.5 / simulation_spatial_unit, derivative);
    }

    // Take the gauge covariant derivative of a fermion field with a specified field-index, at a specified simulation location,
    // along a specified spatial axis, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, uint field_index, out FermionFieldState derivative)
    {
        spatial_derivative(axis, position, field_index, crnt_fermions_lattice_buffer, crnt_gauge_potentials_lattice_buffer, derivative);
    }

    // Take the gauge covariant gradient of a fermion field with a specified field-index, at a specified simulation location,
    // along all spacetime axes, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_gradient(float3 position, uint fieldIndex, out FermionFieldSpacetimeGradient gradient)
    {
        temporal_derivative(position, fieldIndex, gradient[0]);
        spatial_derivative(0, position, fieldIndex, gradient[1]);
        spatial_derivative(1, position, fieldIndex, gradient[2]);
        spatial_derivative(2, position, fieldIndex, gradient[3]);
    }

    // Take the gauge covariant gradient of a fermion field with a specified field-index, at a specified simulation location,
    // along all spatial axes, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_gradient(float3 position, uint fieldIndex, out FermionFieldSpatialGradient gradient)
    {
        spatial_derivative(0, position, fieldIndex, gradient[0]);
        spatial_derivative(1, position, fieldIndex, gradient[1]);
        spatial_derivative(2, position, fieldIndex, gradient[2]);
    }
}

#endif
