#ifndef SIMULATION_POKES_PROCESSING_USER_CENTERED_INTERACTIVE
#define SIMULATION_POKES_PROCESSING_USER_CENTERED_INTERACTIVE

#include "../../core/formalisms/dirac_formalism.hlsl"
#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/structures/simulation_poke_data.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../../core/simulation_globals.hlsl"


namespace SimulationPokesProcessing
{
    /// Implementation of pokes application as user-centered interactive pokes - i.e. pokes applied with a
    /// structure that "feels natural" to a user poking the simulation
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace UserCenteredInteractive
    {
        // A structure used to cache processed data associated with a poke or necessary for its application
        struct PokeApplicationCache
        {
            half3 position;
            SimulationPokeData raw_poke_data;
            half poking_strength;
            half poking_radius;
            half3 poking_position;
            half3 sweep_delta;
            half3 distance_vector_to_poke_sweep;
            int poke_mask;
            half distance_from_poking_sweep;
            half normalized_distance_from_poking_sweep;
        };

        // This function computes the distance vector from a point to the closest point on a line segment defined
        // by the "poke sweep" (i.e. the line segment between the poke position and the poke position + the poke delta)
        half3 _compute_distance_vector_to_poke_sweep(half3 position, half3 poking_position, half3 poking_delta)
        {
            half3 AP = position - poking_position;
            half3 AB = -poking_delta;
            half AB_lengthSquared = dot(AB, AB);
            if (AB_lengthSquared == 0.0f) return AP;
            half t = dot(AP, AB) / AB_lengthSquared;
            t = clamp(t, 0.0f, 1.0f);
            half3 closestPoint = poking_position + t * AB;
            return position - closestPoint;
        }

        // Constructs a structure of computed cached properties associated with a poke
        void _construct_poke_application_data(half3 position, SimulationPokeData poke_data, out PokeApplicationCache poke_application_data)
        {
            poke_application_data.position = position;
            poke_application_data.raw_poke_data = poke_data;
            poke_application_data.poking_strength = poke_data[0] / 1000.0f;
            poke_application_data.poking_radius = poke_data[1];
            poke_application_data.poking_position = half3(poke_data[2], poke_data[3], poke_data[4]);
            poke_application_data.sweep_delta = half3(poke_data[5], poke_data[6], poke_data[7]);
            poke_application_data.poke_mask = poke_data[8] & simulation_field_mask;
            poke_application_data.distance_vector_to_poke_sweep = _compute_distance_vector_to_poke_sweep(poke_application_data.position, poke_application_data.poking_position, poke_application_data.sweep_delta);
            poke_application_data.distance_from_poking_sweep = length(poke_application_data.distance_vector_to_poke_sweep);
            poke_application_data.normalized_distance_from_poking_sweep = poke_application_data.distance_from_poking_sweep / poke_application_data.poking_radius;
        }

        // Will return a semi-random number depending on the poke data - ensuring consistency between a poke
        // and the data it affects
        half _get_random_number_for_poke_data(SimulationPokeData raw_poke_data, int seed = 0)
        {
            half sum = seed;
            for (uint i = 0; i < 9; i++) sum += raw_poke_data[i];
            half mixedValue = sum * seed % (seed + 1);
            return mixedValue;
        }

        // This function determines whether a field is active for a given field index
        int _poking_active_for_field(int poke_mask, int global_field_index)
        {
            return (poke_mask & 1 << global_field_index) != 0 ? 1 : 0;
        }

        half _poking_profile(PokeApplicationCache poke_application_data)
        {
            half r = poke_application_data.normalized_distance_from_poking_sweep;
            return exp(-r * r);
        }

        void _fermion_state(PokeApplicationCache poke_application_data, out FermionFieldState new_fermion_state)
        {
            half mass = 1; // since a random field is chosen, the effective mass involved in the fermion state construction would be hardcoded
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
            for (int i = 0; i < FERMION_FIELDS_COUNT; i++) number_of_poke_participating_fermion_fields += _poking_active_for_field(poke_application_data.poke_mask, i);
            if (number_of_poke_participating_fermion_fields == 0) return;
            half poke_strength_at_position = poke_application_data.poking_strength * _poking_profile(poke_application_data);
            FermionFieldState new_fermion_state;
            _fermion_state(poke_application_data, new_fermion_state);
            for (uint i = 0; i < 5; i++)
            {
                // Obtain a random field index for the poke data - associated with a given unique raw poke data (ensuring all points affected by the same poke affect the same field)
                half randomly_chosen_participating_field = round(_get_random_number_for_poke_data(poke_application_data.raw_poke_data, i + 1)) % number_of_poke_participating_fermion_fields + 1;
                uint random_field_index;
                for (random_field_index = 0; random_field_index < FERMION_FIELDS_COUNT; random_field_index++)
                {
                    randomly_chosen_participating_field -= _poking_active_for_field(poke_application_data.poke_mask, random_field_index);
                    if (randomly_chosen_participating_field <= 0) break;
                }
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

		// Compute the electric and magnetic field increments associated with a poke
        void _build_field_increments(PokeApplicationCache poke_application_data, out half3 electric_field_increment, out half3 magnetic_field_increment)
        {
            half3 sweep_direction_unit_vector = poke_application_data.sweep_delta;
			sweep_direction_unit_vector.z = 1;
			sweep_direction_unit_vector = normalize(sweep_direction_unit_vector);
            half poking_profile = _poking_profile(poke_application_data);
            half radius_sqrd = poke_application_data.poking_radius * poke_application_data.poking_radius;
            const half poke_wavelength_scale = 2.0f;
            half effective_radius_sqrd_for_gradient = radius_sqrd * (poke_wavelength_scale * poke_wavelength_scale);
            half3 gradient_of_poking_profile = (-2.0f / effective_radius_sqrd_for_gradient) * poking_profile * poke_application_data.distance_vector_to_poke_sweep;
            half electric_strength_scale = poke_application_data.poking_strength;
            electric_field_increment = electric_strength_scale * cross(gradient_of_poking_profile, sweep_direction_unit_vector);
            magnetic_field_increment = half3(0.0f, 0.0f, 0.0f);
        }

		// Accumulate the gauge field increments associated with a poke
        void _accumulate_gauge_packs(int poke_mask, half3 electric_delta, half3 magnetic_delta, inout GaugeSymmetriesVectorPack crnt_electric_state, inout GaugeSymmetriesVectorPack prev_electric_state, inout GaugeSymmetriesVectorPack crnt_magnetic_state, inout GaugeSymmetriesVectorPack prev_magnetic_state)
        {
            GaugeSymmetriesVectorPack electric_addition, magnetic_addition;
            [unroll]
            for (uint i = 0; i < 12; i++)
            {
                const int active = _poking_active_for_field(poke_mask, (int)i + 8);
                half active_factor = (half)active;
                electric_addition[i] = active_factor * half4(0.0f, electric_delta) / (1.0f + length(crnt_electric_state[i]));
                magnetic_addition[i] = active_factor * half4(0.0f, magnetic_delta) / (1.0f + length(crnt_magnetic_state[i]));
            }
            GaugeSymmetriesVectorPackMath::sum(crnt_electric_state, electric_addition, crnt_electric_state);
            GaugeSymmetriesVectorPackMath::sum(crnt_magnetic_state, magnetic_addition, crnt_magnetic_state);
            GaugeSymmetriesVectorPackMath::sum(prev_electric_state, electric_addition, prev_electric_state);
            GaugeSymmetriesVectorPackMath::sum(prev_magnetic_state, magnetic_addition, prev_magnetic_state);
        }

		// Apply a poke to the gauge fields at a given position given its poke data cache
        void _apply_poke_to_gauge_fields(half3 position, PokeApplicationCache poke_application_data)
        {
            half3 electric_delta, magnetic_delta; 
            _build_field_increments(poke_application_data, electric_delta, magnetic_delta);

            uint lattice_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack current_electric_pack = crnt_electric_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack previous_electric_pack = prev_electric_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack current_magnetic_pack = crnt_magnetic_strengths_lattice_buffer[lattice_index];
            GaugeSymmetriesVectorPack previous_magnetic_pack = prev_magnetic_strengths_lattice_buffer[lattice_index];

            _accumulate_gauge_packs(poke_application_data.poke_mask, electric_delta, magnetic_delta, current_electric_pack, previous_electric_pack, current_magnetic_pack, previous_magnetic_pack);

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
            for (int i = 0; i < POKES_BUFFER_LENGTH; i++)
            {
                SimulationPokeData raw_poke_data = simulation_pokes_buffer[i];
                process_poke(position, raw_poke_data);
            }
        }
    }
}

#endif
