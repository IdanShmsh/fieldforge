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
    void temporal_derivative(half3 position, uint field_index, out FermionFieldState derivative)
    {
        uint lattice_buffer_index;
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState prev_fermion_state = prev_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldState crnt_fermion_state = crnt_fermions_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index ^ 1);
        FermionFieldState prev_weak_partner_state = prev_fermions_lattice_buffer[lattice_buffer_index];
        lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack gauge_potentials = prev_gauge_potentials_lattice_buffer[lattice_buffer_index];
        half3 coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(field_index);
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
    void spatial_derivative(uint axis, half3 position, uint field_index, FermionLatticeBuffer fermion_lattice_buffer, GaugeLatticeBuffer gauge_potentials_lattice_buffer, out FermionFieldState derivative)
    {
        FermionFieldStateOps::empty(derivative);
        if (axis > SPATIAL_DIMENSIONALITY - 1) return;
        half3 offset = half3(0, 0, 0);
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
        half3 coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(field_index);
        WilsonFormalism::backward_parallel_transport_fermion(
            neighboring_fermion_state1,
            neighboring_weak_partner_state1,
            link_gauge_potentials1,
            axis + 1,
            coupling_constants,
            weakDoubletIndex,
            neighboring_fermion_state1);
        WilsonFormalism::parallel_transport_fermion(
            neighboring_fermion_state2,
            neighboring_weak_partner_state2,
            link_gauge_potentials2,
            axis + 1,
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
    void spatial_derivative(uint axis, half3 position, uint field_index, out FermionFieldState derivative)
    {
        spatial_derivative(axis, position, field_index, crnt_fermions_lattice_buffer, crnt_gauge_potentials_lattice_buffer, derivative);
    }

    // Take the gauge covariant spatial curvature (second derivative) of a fermion field with a specified field-index, at a specified simulation location,
    // along a specified spatial axis, in a specified fermion lattice buffer and a specified gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_curvature(uint axis, half3 position, uint field_index, FermionLatticeBuffer fermion_lattice_buffer, GaugeLatticeBuffer gauge_potentials_lattice_buffer, out FermionFieldState curvature)
    {
        FermionFieldStateOps::empty(curvature);
        if (axis > SPATIAL_DIMENSIONALITY - 1) return;
        half3 offset = half3(0, 0, 0);
        offset[axis] = 1;
        uint lattice_buffer_index;
        lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState center_fermion_state = fermion_lattice_buffer[lattice_buffer_index];
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
        half3 coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(field_index);
        WilsonFormalism::backward_parallel_transport_fermion(
            neighboring_fermion_state1,
            neighboring_weak_partner_state1,
            link_gauge_potentials1,
            axis + 1,
            coupling_constants,
            weakDoubletIndex,
            neighboring_fermion_state1);
        WilsonFormalism::parallel_transport_fermion(
            neighboring_fermion_state2,
            neighboring_weak_partner_state2,
            link_gauge_potentials2,
            axis + 1,
            coupling_constants,
            weakDoubletIndex,
            neighboring_fermion_state2);
        FermionFieldState sum_of_neighbors;
        FermionFieldStateMath::sum(neighboring_fermion_state2, neighboring_fermion_state1, sum_of_neighbors);
        FermionFieldState twice_center;
        FermionFieldStateMath::rscl(center_fermion_state, 2, twice_center);
        FermionFieldState second_difference;
        FermionFieldStateMath::sub(sum_of_neighbors, twice_center, second_difference);
        FermionFieldStateMath::rscl(second_difference, 1 / (simulation_spatial_unit * simulation_spatial_unit), curvature);
    }

    // Take the gauge covariant spatial curvature (second derivative) of a fermion field with a specified field-index, at a specified simulation location,
    // along a specified spatial axis, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_curvature(uint axis, half3 position, uint field_index, out FermionFieldState curvature)
    {
        spatial_curvature(axis, position, field_index, crnt_fermions_lattice_buffer, crnt_gauge_potentials_lattice_buffer, curvature);
    }

    // Take the gauge covariant spatial laplacian of a fermion field with a specified field-index, at a specified simulation location,
    // along all spatial axes, in a specified fermion lattice buffer and a specified gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_laplacian(half3 position, uint field_index, FermionLatticeBuffer fermion_lattice_buffer, GaugeLatticeBuffer gauge_potentials_lattice_buffer, out FermionFieldState laplacian)
    {
        FermionFieldStateOps::empty(laplacian);
        FermionFieldState axis_curvature;
        spatial_curvature(0, position, field_index, fermion_lattice_buffer, gauge_potentials_lattice_buffer, axis_curvature);
        FermionFieldStateMath::sum(laplacian, axis_curvature, laplacian);
        spatial_curvature(1, position, field_index, fermion_lattice_buffer, gauge_potentials_lattice_buffer, axis_curvature);
        FermionFieldStateMath::sum(laplacian, axis_curvature, laplacian);
        spatial_curvature(2, position, field_index, fermion_lattice_buffer, gauge_potentials_lattice_buffer, axis_curvature);
        FermionFieldStateMath::sum(laplacian, axis_curvature, laplacian);
    }

    // Take the gauge covariant spatial laplacian of a fermion field with a specified field-index, at a specified simulation location,
    // along all spatial axes, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_laplacian(half3 position, uint field_index, out FermionFieldState laplacian)
    {
        spatial_laplacian(position, field_index, crnt_fermions_lattice_buffer, crnt_gauge_potentials_lattice_buffer, laplacian);
    }

    // Take the gauge covariant gradient of a fermion field with a specified field-index, at a specified simulation location,
    // along all spacetime axes, in the current fermion lattice buffer and the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_gradient(half3 position, uint fieldIndex, out FermionFieldSpacetimeGradient gradient)
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
    void spatial_gradient(half3 position, uint fieldIndex, out FermionFieldSpatialGradient gradient)
    {
        spatial_derivative(0, position, fieldIndex, gradient[0]);
        spatial_derivative(1, position, fieldIndex, gradient[1]);
        spatial_derivative(2, position, fieldIndex, gradient[2]);
    }
}

#endif
