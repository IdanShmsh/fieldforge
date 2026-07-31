#ifndef SIMULATION_POKES_PROCESSING_PHYSICALLY_MEANINGFUL
#define SIMULATION_POKES_PROCESSING_PHYSICALLY_MEANINGFUL

#include "_simulation_poking.hlsl"
#include "../../core/formalisms/dirac_formalism.hlsl"
#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/gauge_symmeyries_vector_pack_ops.hlsl"


namespace SimulationPokesProcessing
{
    /// Implementation of pokes application as physically-meaningful pokes - i.e. pokes applied as a
    /// physically-motivated current/charge distribution along the poke sweep.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    /// * Shared poke helpers (PokeApplicationCache, _construct_poke_application_data,
    ///   _get_random_number_for_poke_data, _poking_active_for_field, ...) live in _simulation_poking.hlsl.
    namespace PhysicallyMeaningful
    {
        // Determining how strong the poke of a fermion is at a given distance from the poke sweep
        half _fermion_poking_profile(PokeApplicationCache poke_application_data)
        {
            half r = poke_application_data.normalized_distance_from_poking_sweep;
            return exp(-r * r);
        }

        // Construct a fermion state from a given spin vector and a given delta
        void _fermion_state(half mass, PokeApplicationCache poke_application_data, out FermionFieldState new_fermion_state)
        {
            half3 spin_vector = poke_application_data.sweep_delta;
            spin_vector.z = 1;
            DiracFormalism::construct_spin_state(normalize(spin_vector), poke_application_data.sweep_delta, mass, new_fermion_state);
        }

        // Apply a poke to the fermion fields at a given position given its poke data cache
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _apply_poke_to_fermion_fields(half3 position, PokeApplicationCache poke_application_data)
        {
            int number_of_poke_participating_fermion_fields = 0;
            for (int field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++) number_of_poke_participating_fermion_fields += _poking_active_for_field(poke_application_data.poke_mask, field_index);
            if (number_of_poke_participating_fermion_fields == 0) return;
            half poke_strength_at_position = poke_application_data.poking_strength * _fermion_poking_profile(poke_application_data);
            FermionFieldState new_fermion_state;
            for (uint injection_index = 0; injection_index < 5; injection_index++)
            {
                // Obtain a random field index for the poke data - associated with a given unique raw poke data (ensuring all points affected by the same poke affect the same field)
                int randomly_chosen_participating_field = (int)(_get_random_number_for_poke_data(poke_application_data.raw_poke_data, injection_index + 1) % (uint)number_of_poke_participating_fermion_fields) + 1;
                uint random_field_index;
                for (random_field_index = 0; random_field_index < FERMION_FIELDS_COUNT; random_field_index++)
                {
                    randomly_chosen_participating_field -= _poking_active_for_field(poke_application_data.poke_mask, random_field_index);
                    if (randomly_chosen_participating_field <= 0) break;
                }
				FermionFieldProperties field_properties = fermion_field_properties[random_field_index];
				half mass = field_properties.field_mass;
				_fermion_state(mass, poke_application_data, new_fermion_state);
                half field_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, random_field_index);
                FermionFieldState crnt_field_state = crnt_fermions_lattice_buffer[field_buffer_index];
                FermionFieldState prev_field_state = prev_fermions_lattice_buffer[field_buffer_index];
                half field_norm_sqrd = FermionFieldStateMath::norm_sqrd(crnt_field_state);
                FermionFieldState electric_additiond_field_state;
                FermionFieldStateMath::rscl(new_fermion_state, poke_strength_at_position / (1 + field_norm_sqrd), electric_additiond_field_state);
                FermionFieldStateMath::sum(crnt_field_state, electric_additiond_field_state, crnt_field_state);
                FermionFieldStateMath::sum(prev_field_state, electric_additiond_field_state, prev_field_state);
                crnt_fermions_lattice_buffer[field_buffer_index] = crnt_field_state;
                prev_fermions_lattice_buffer[field_buffer_index] = prev_field_state;
            }
        }

		// Determining how strong the poke of a gauge is at a given distance from the poke sweep
        void _gauge_poking_profile(half3 distance_vector, half poking_sigma, out half tube, out half3 tube_gradient)
        {
            half sigma_sq = max(poking_sigma * poking_sigma, 1e-6f);
            half r2 = dot(distance_vector, distance_vector);
            tube = exp(-r2 / (2.0f * sigma_sq));
            tube_gradient = -(distance_vector / sigma_sq) * tube;
        }

		// Determining the gauge current density of a poke at a given distance from the poke sweep
        half3 _current_density(half charge_per_length, half delta_time, half3 direction_hat, half tube, half poking_sigma)
        {
            const half TWO_PI = 6.28318530718f;
            half denom = max(TWO_PI * max(poking_sigma * poking_sigma, 1e-6f) * max(delta_time, 1e-6f), 1e-6f);
            return (charge_per_length / denom) * direction_hat * tube;
        }

		// Construct a gauge state from a given spin vector and a given delta
        void _build_field_increments(PokeApplicationCache poke_cache, out half3 electric_delta, out half3 magnetic_delta)
        {
            half3 direction_hat = poke_cache.sweep_delta;
			direction_hat.z = 1;
			direction_hat = normalize(direction_hat);
            half poking_sigma = max(poke_cache.poking_radius, 1e-6f);
            half3 distance_vector = poke_cache.distance_vector_to_poke_sweep;
            half tube; half3 tube_gradient;
            _gauge_poking_profile(distance_vector, poking_sigma, tube, tube_gradient);
            half delta_time = max(simulation_temporal_unit, 1e-6f);
            half charge_per_length = poke_cache.poking_strength;

            // Primary increments
            half3 current_density = _current_density(charge_per_length, delta_time, direction_hat, tube, poking_sigma);
            electric_delta = -(2.0f * delta_time) * current_density;
            magnetic_delta = (2.0f * delta_time) * cross(direction_hat, tube_gradient);

            // Divergent E term (finite-radius line charge)
            const half TWO_PI = 6.28318530718f;
            half sigma_sq = max(poking_sigma * poking_sigma, 1e-6f);
            half r2 = dot(distance_vector, distance_vector);
            half r = max(sqrt(r2), 1e-6f);
            half rho0 = charge_per_length / max(TWO_PI * sigma_sq, 1e-6f);
            half one_minus_exp = 1.0f - exp(-r2 / (2.0f * sigma_sq));
            half radial_electric_magnitude = (rho0 * sigma_sq / r) * one_minus_exp;
            half3 radial_direction = distance_vector / r;
            electric_delta += radial_electric_magnitude * radial_direction;
        }

		// Accumulate the gauge fields of a poke at a given position given its poke data cache
        void _accumulate_gauge_packs(PokeApplicationCache poke_application_data, half3 electric_delta, half3 magnetic_delta, inout GaugeSymmetriesVectorPack crnt_electric_state, inout GaugeSymmetriesVectorPack prev_electric_state, inout GaugeSymmetriesVectorPack crnt_magnetic_state, inout GaugeSymmetriesVectorPack prev_magnetic_state)
        {
            GaugeSymmetriesVectorPack electric_addition, magnetic_addition;
            [unroll]
            for (uint symmetry_index = 0; symmetry_index < 12; symmetry_index++)
            {
                const int active = _poking_active_for_field(poke_application_data.poke_mask, (int)symmetry_index + 8);
                half active_factor = (half)active;
                electric_addition[symmetry_index] = active_factor * half4(0.0f, electric_delta) / (1.0f + length(crnt_electric_state[symmetry_index]));
                magnetic_addition[symmetry_index] = active_factor * half4(0.0f, magnetic_delta) / (1.0f + length(crnt_magnetic_state[symmetry_index]));
            }
            GaugeSymmetriesVectorPackMath::sum(crnt_electric_state, electric_addition, crnt_electric_state);
            GaugeSymmetriesVectorPackMath::sum(prev_electric_state, electric_addition, prev_electric_state);
            GaugeSymmetriesVectorPackMath::sum(crnt_magnetic_state, magnetic_addition, crnt_magnetic_state);
            GaugeSymmetriesVectorPackMath::sum(prev_magnetic_state, magnetic_addition, prev_magnetic_state);
        }

		// Apply a poke to the gauge fields at a given position given its poke data cache
        void _apply_poke_to_gauge_fields(half3 position, PokeApplicationCache poke_cache)
        {
            half3 electric_delta, magnetic_delta; _build_field_increments(poke_cache, electric_delta, magnetic_delta);

            uint lattice_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack current_electric_pack = crnt_electric_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack previous_electric_pack = prev_electric_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack current_magnetic_pack = crnt_magnetic_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack previous_magnetic_pack = prev_magnetic_strengths_lattice_buffer[lattice_index];

            _accumulate_gauge_packs(poke_cache, electric_delta, magnetic_delta, current_electric_pack, previous_electric_pack, current_magnetic_pack, previous_magnetic_pack);

            crnt_electric_strengths_lattice_buffer[lattice_index] = current_electric_pack;
            prev_electric_strengths_lattice_buffer[lattice_index] = previous_electric_pack;
            crnt_magnetic_strengths_lattice_buffer[lattice_index] = current_magnetic_pack;
            prev_magnetic_strengths_lattice_buffer[lattice_index] = previous_magnetic_pack;
        }

        // Process a single poke at a given position
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void process_poke(half3 position, SimulationPokeData raw_poke_data)
        {
            if (raw_poke_data[0] == 0) return;
            PokeApplicationCache poke_application_data;
            _construct_poke_application_data(position, raw_poke_data, poke_application_data);
            _apply_poke_to_fermion_fields(position, poke_application_data);
            _apply_poke_to_gauge_fields(position, poke_application_data);
        }

        // Process all pokes in the simulation's pokes buffer
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void process_pokes(half3 position)
        {
            for (int poke_index = 0; poke_index < POKES_BUFFER_LENGTH; poke_index++)
            {
                SimulationPokeData raw_poke_data = simulation_pokes_buffer[poke_index];
                process_poke(position, raw_poke_data);
            }
        }
    }
}

#endif
