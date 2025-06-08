#ifndef GAUGE_INTERACTION
#define GAUGE_INTERACTION

#include "dirac_formalism.hlsl"
#include "fermion_state_symmetry_transformations.hlsl"
#include "../math/gauge_symmetries_vector_pack_math.hlsl"

namespace GaugeInteraction
{
    // Get the gauge charge of a fermion for a given gauge field index
    float _get_gauge_charge(uint symmetry_index, FermionFieldProperties fermion_field_properties)
    {
        return symmetry_index == 0 ? fermion_field_properties.u1_interaction_coupling :
               symmetry_index < 4 ? fermion_field_properties.su2_interaction_coupling :
                       fermion_field_properties.su3_interaction_coupling;
    }

    // Apply the gauge generator for a given gauge field index
    void _apply_symmetry_generator(uint gauge_field_index, FermionFieldState fermion_state, FermionFieldState fermion_weak_partner_state, uint fermion_field_index, out FermionFieldState transformed_fermion_state)
    {
        if (gauge_field_index == 0)
        {
            transformed_fermion_state = fermion_state;
        }
        else if (gauge_field_index < 4)
        {
            FermionFieldState _;
            if (fermion_field_index % 2 == 0) FermionStateSymmetryTransformations::apply_sigma(fermion_state, fermion_weak_partner_state, gauge_field_index - 1, transformed_fermion_state, _);
            else FermionStateSymmetryTransformations::apply_sigma(fermion_weak_partner_state, fermion_state, gauge_field_index - 1, _, transformed_fermion_state);
        }
        else
        {
            FermionStateSymmetryTransformations::apply_lambda(fermion_state, gauge_field_index - 4, transformed_fermion_state);
        }
    }

    // Compute the gauge current for a fermion field at a given position in a specified fermion lattice buffer
    void compute_fermion_gauge_currents_at_position(float3 position, uint field_index, FermionLatticeBuffer fermion_lattice_buffer, out GaugeSymmetriesVectorPack fermion_gauge_currents)
    {
        GaugeSymmetriesVectorPackOps::empty(fermion_gauge_currents);
        if (!SimulationDataOps::is_fermion_field_active(field_index)) return;

        uint fermion_lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState fermion_state = fermion_lattice_buffer[fermion_lattice_buffer_index];
        if (FermionFieldStateOps::is_zero(fermion_state, 1e-2)) return;

        uint weak_partner_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index ^ 1);
        FermionFieldState weak_partner_state = fermion_lattice_buffer[weak_partner_buffer_index];

        FermionFieldProperties props = fermion_field_properties[field_index];
        FermionFieldState adjoint;
        FermionFieldStateMath::adjoint(fermion_state, adjoint);

        for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++)
        {
            fermion_gauge_currents[symmetry_index] = float4(0, 0, 0, 0);
            if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
            float charge = _get_gauge_charge(symmetry_index, props);
            if (charge == 0) continue;

            FermionFieldState symmetry_transformed_state;
            _apply_symmetry_generator(symmetry_index, fermion_state, weak_partner_state, field_index, symmetry_transformed_state);

            for (uint mu = 0; mu < 4; mu++)
            {
                FermionFieldState gamma_transformed_state;
                DiracFormalism::apply_gamma(symmetry_transformed_state, mu, gamma_transformed_state);
                float current_component_value = charge * FermionFieldStateMath::inner_product(adjoint, gamma_transformed_state).x;
                fermion_gauge_currents[symmetry_index][mu] = current_component_value;
            }
        }
    }

    // Compute the gauge current for a fermion field at a given position in the current fermions lattice buffer
    void compute_fermion_gauge_currents_at_position(float3 position, uint field_index, out GaugeSymmetriesVectorPack fermion_gauge_currents)
    {
        compute_fermion_gauge_currents_at_position(position, field_index, crnt_fermions_lattice_buffer, fermion_gauge_currents);
    }

    // Compute the total gauge current at a given position by summing the contributions from all fermion fields in a specified fermions lattice buffer
    void compute_total_gauge_currents_at_position(float3 position, FermionLatticeBuffer fermion_lattice_buffer, out GaugeSymmetriesVectorPack total_current)
    {
        GaugeSymmetriesVectorPackOps::empty(total_current);
        for (uint field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
        {
            GaugeSymmetriesVectorPack fermion_gauge_current;
            compute_fermion_gauge_currents_at_position(position, field_index, fermion_lattice_buffer, fermion_gauge_current);
            GaugeSymmetriesVectorPackMath::sum(fermion_gauge_current, total_current, total_current);
        }
    }

    // Compute the total gauge current at a given position by summing the contributions from all fermion fields in the current fermions lattice buffer
    void compute_total_gauge_currents_at_position(float3 position, out GaugeSymmetriesVectorPack total_current)
    {
        compute_total_gauge_currents_at_position(position, crnt_fermions_lattice_buffer, total_current);
    }

    // Compute the interaction potential energy between provided gauge potentials and total currents
    float compute_interaction_potential_energy(GaugeSymmetriesVectorPack gauge_potentials, GaugeSymmetriesVectorPack total_currents)
    {
        return GaugeSymmetriesVectorPackMath::dot(gauge_potentials, total_currents);
    }
}

#endif
