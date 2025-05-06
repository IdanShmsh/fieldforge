#ifndef FERMION_FIELD_EVOLUTION_DIRAC_WILSON_LEAPFROG
#define FERMION_FIELD_EVOLUTION_DIRAC_WILSON_LEAPFROG

#include "../../core/analysis/fermion_field_gauge_covariant_wilson_differentials.hlsl"
#include "../../core/formalisms/dirac_formalism.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/fermion_field_state_ops.hlsl"

namespace FermionFieldEvolution
{
    /// The implementation of a Dirac-Wilson leapfrog evolution of fermion fields.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace DiracWilsonLeapfrog
    {
        // A structure used to cache processed data necessary for performing the evolution
        struct EvolutionCache
        {
            float3 position;
            uint field_index;
            uint buffer_index;
            FermionFieldState previous_state;
            FermionFieldState field_state;
            FermionFieldState previous_weak_partner_state;
            FermionFieldState weak_partner_state;
            GaugeSymmetriesVectorPack previous_gauge_state;
            GaugeSymmetriesVectorPack gauge_state;
            FermionFieldProperties field_properties;
            float3 coupling_constants;
            FermionFieldSpacetimeGradient spacetime_gradient;
            bool weak_doublet_index;
        };

        // Obtain data needed to perform the evolution
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        void _obtain_evolution_data_at_position(float3 position, uint fermion_field_index, out EvolutionCache evolution_data)
        {
            evolution_data.position = position;
            evolution_data.field_index = fermion_field_index;
            evolution_data.buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, fermion_field_index);
            evolution_data.previous_state = prev_fermions_lattice_buffer[evolution_data.buffer_index];
            evolution_data.field_state = crnt_fermions_lattice_buffer[evolution_data.buffer_index];
            uint weak_partner_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, fermion_field_index ^ 1);
            evolution_data.previous_weak_partner_state = prev_fermions_lattice_buffer[weak_partner_buffer_index];
            evolution_data.weak_partner_state = crnt_fermions_lattice_buffer[weak_partner_buffer_index];
            uint gauge_fields_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            evolution_data.previous_gauge_state = prev_gauge_potentials_lattice_buffer[gauge_fields_buffer_index];
            evolution_data.gauge_state = crnt_gauge_potentials_lattice_buffer[gauge_fields_buffer_index];
            evolution_data.field_properties = fermion_field_properties[fermion_field_index];
            evolution_data.coupling_constants = SimulationDataOps::obtain_fermion_coupling_constants_tuple(fermion_field_index);
            FermionFieldGaugeCovariantWilsonDifferentials::spacetime_gradient(position, fermion_field_index, evolution_data.spacetime_gradient);
            evolution_data.weak_doublet_index = fermion_field_index % 2 == 0;
        }

        // Perform the Dirac-Wilson leapfrog evolution of the fermion field provided the cached evolution data
        void _dirac_evolution(EvolutionCache evolution_cache, out FermionFieldState next_state)
        {
            // Would represent the slope given by the gauge interaction of the field.
            // This kind of evolution is unitary, so we normalize the next state to keep the norm the same.
            FermionFieldState temporal_slope;

            // Factor in the mass term
            FermionFieldStateMath::scl(evolution_cache.field_state, float2(0, evolution_cache.field_properties.field_mass), temporal_slope);

            // Factor and sum the kinetic terms
            FermionFieldState tmp;
            DiracFormalism::gamma1(evolution_cache.spacetime_gradient[1], tmp);
            FermionFieldStateMath::sub(temporal_slope, tmp, temporal_slope);
            DiracFormalism::gamma2(evolution_cache.spacetime_gradient[2], tmp);
            FermionFieldStateMath::sub(temporal_slope, tmp, temporal_slope);
            DiracFormalism::gamma3(evolution_cache.spacetime_gradient[3], tmp);
            FermionFieldStateMath::sub(temporal_slope, tmp, temporal_slope);

            // Multiply all by gamma0
            DiracFormalism::gamma0(temporal_slope, temporal_slope);

            // Weighing the slope with the temporal unit (\Delta t)
            FermionFieldStateMath::rscl(temporal_slope, 2 * simulation_temporal_unit, temporal_slope);

            // Parallel transport just the previous state initially
            next_state = evolution_cache.previous_state;
            WilsonFormalism::backward_parallel_transport_fermion(next_state, evolution_cache.previous_weak_partner_state, evolution_cache.previous_gauge_state, 0, evolution_cache.coupling_constants, evolution_cache.weak_doublet_index, next_state);

            // Sum the temporal slope with the previous state
            FermionFieldStateMath::sum(next_state, temporal_slope, next_state);

            // Parallel transport the entire result
            WilsonFormalism::backward_parallel_transport_fermion(next_state, evolution_cache.weak_partner_state, evolution_cache.gauge_state, 0, evolution_cache.coupling_constants, evolution_cache.weak_doublet_index, next_state);
        }

        // Ensure the validity of the evolution result
        void _ensure_evolution_result_validity(FermionFieldState state, out FermionFieldState valid_state)
        {
            for (uint c = 0; c < 12; c++)
            {
                // Discard any state that's "not a number" or infinity.
                const bool componentValueValid = !(any(isnan(state[c])) || any(isinf(state[c])));
                valid_state[c] = componentValueValid ? state[c] : float2(0, 0);
            }
        }

        // Ensure the validity of the evolution result
        void _apply_density_limit(FermionFieldState state, out FermionFieldState limited_state)
        {
            // Use a harmonic mean to limit the norm of the state to the configured maximum
            limited_state = state;
            float dirac_norm = abs(DiracFormalism::dirac_norm(state));
            if (dirac_norm == 0) return;
            float target_norm = CommonMath::harmonic_mean(dirac_norm, simulation_fermion_density_limit);
            float scale_factor = target_norm / dirac_norm;
            FermionFieldStateMath::rscl(limited_state, scale_factor, limited_state);
        }

        // Propagate the field to the next state
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _evolve_and_write_next(EvolutionCache evolution_data)
        {
            FermionFieldState next_fermion_state;

            // Evolve the field
            _dirac_evolution(evolution_data, next_fermion_state);

            // Ensure the validity of the evolution result
            _ensure_evolution_result_validity(next_fermion_state, next_fermion_state);

            // Apply the density limit to the state
            _apply_density_limit(next_fermion_state, next_fermion_state);

            // Finally, write the state to the buffer.
            next_fermions_lattice_buffer[evolution_data.buffer_index] = next_fermion_state;
        }

        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void fermion_evolution(float3 position, uint fermion_field_index)
        {
            if (!SimulationDataOps::is_fermion_field_active(fermion_field_index)) return;

            // Load data needed for the evolution
            EvolutionCache evolution_data;
            _obtain_evolution_data_at_position(position, fermion_field_index, evolution_data);

            // Perform the evolution
            _evolve_and_write_next(evolution_data);
        }

        // Normal evolution function
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void fermion_evolution(float3 position)
        {
            for (uint i = 0; i < 8; i++) fermion_evolution(position, i);
        }
    }
}

#endif
