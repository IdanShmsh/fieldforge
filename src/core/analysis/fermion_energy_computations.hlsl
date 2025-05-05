#ifndef FERMION_ENERGY_COMPUTATIONS
#define FERMION_ENERGY_COMPUTATIONS

#include "../ops/simulation_data_ops.hlsl"
#include "../formalisms/dirac_formalism.hlsl"
#include "fermion_field_gauge_covariant_wilson_differentials.hlsl"

/// This namespace implements functions used to compute the energy density of fermion fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FermionEnergyComputations
{
    // Compute the energy density of a fermion field given its local configuration (state , gradient , mass).
    float compute_energy_density(FermionFieldState fermion_state, FermionFieldSpacetimeGradient fermion_field_spacetime_gradient, float fermion_mass)
    {
        float energy = 0;
        FermionFieldState adjoint;
        FermionFieldStateMath::adjoint(fermion_state, adjoint);
        FermionFieldState tmp;
        DiracFormalism::apply_gamma(fermion_field_spacetime_gradient[0], 0, tmp);
        energy += abs(FermionFieldStateMath::inner_product(adjoint, tmp).x);
        energy += abs(fermion_mass * DiracFormalism::dirac_norm(fermion_state));
        return energy;
    }

    // Compute the energy density of a free fermion field with a specified field-index at a specified simulation location.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float compute_free_energy_density(float3 position, uint field_index)
    {
        if (!SimulationDataOps::is_fermion_field_active(field_index)) return 0;
        uint lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState fermion_state = crnt_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldSpacetimeGradient fermion_field_spacetime_gradient;
        FermionFieldStateDifferentials::spacetime_gradient(position, field_index, fermion_field_spacetime_gradient);
        float fermion_mass = fermion_field_properties[field_index].field_mass;
        return compute_energy_density(fermion_state, fermion_field_spacetime_gradient, fermion_mass);
    }

    // Compute the energy density of a free fermion field with a specified field-index at a specified simulation location.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float compute_energy_density(float3 position, uint field_index)
    {
        if (!SimulationDataOps::is_fermion_field_active(field_index)) return 0;
        uint lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState fermion_state = crnt_fermions_lattice_buffer[lattice_buffer_index];
        FermionFieldSpacetimeGradient fermion_field_spacetime_gradient;
        FermionFieldGaugeCovariantWilsonDifferentials::spacetime_gradient(position, field_index, fermion_field_spacetime_gradient);
        float fermion_mass = fermion_field_properties[field_index].field_mass;
        return compute_energy_density(fermion_state, fermion_field_spacetime_gradient, fermion_mass);
    }

    // Compute the energy density of all fermion fields at a specified simulation location.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float compute_energy_density(float3 position)
    {
        float total_energy = 0;
        for (uint fieldIndex = 0; fieldIndex < 8; fieldIndex++) total_energy += compute_energy_density(position, fieldIndex);
        return total_energy;
    }
}

#endif
