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
            float3 position;
            SimulationPokeData raw_poke_data;
            float poking_strength;
            float poking_radius;
            float3 poking_position;
            float3 sweep_delta;
            float3 distance_vector_to_poke_sweep;
            int poke_mask;
            float distance_from_poking_sweep;
            float normalized_distance_from_poking_sweep;
        };

        // This function computes the distance vector from a point to the closest point on a line segment defined
        // by the "poke sweep" (i.e. the line segment between the poke position and the poke position + the poke delta)
        float3 _compute_distance_vector_to_poke_sweep(float3 position, float3 poking_position, float3 poking_delta)
        {
            float3 AP = position - poking_position;
            float3 AB = -poking_delta;
            float AB_lengthSquared = dot(AB, AB);
            if (AB_lengthSquared == 0.0f) return AP;
            float t = dot(AP, AB) / AB_lengthSquared;
            t = clamp(t, 0.0f, 1.0f);
            float3 closestPoint = poking_position + t * AB;
            return position - closestPoint;
        }

        // Constructs a structure of computed cached properties associated with a poke
        void _construct_poke_application_data(float3 position, SimulationPokeData poke_data, out PokeApplicationCache poke_application_data)
        {
            poke_application_data.position = position;
            poke_application_data.raw_poke_data = poke_data;
            poke_application_data.poking_strength = poke_data[0] / 1000.0f;
            poke_application_data.poking_radius = poke_data[1];
            poke_application_data.poking_position = float3(poke_data[2], poke_data[3], poke_data[4]);
            poke_application_data.sweep_delta = float3(poke_data[5], poke_data[6], poke_data[7]);
            poke_application_data.poke_mask = poke_data[8] & simulation_field_mask;
            poke_application_data.distance_vector_to_poke_sweep = _compute_distance_vector_to_poke_sweep(poke_application_data.position, poke_application_data.poking_position, poke_application_data.sweep_delta);
            poke_application_data.distance_from_poking_sweep = length(poke_application_data.distance_vector_to_poke_sweep);
            poke_application_data.normalized_distance_from_poking_sweep = poke_application_data.distance_from_poking_sweep / poke_application_data.poking_radius;
        }

        // Will return a semi-random number depending on the poke data - ensuring consistency between a poke
        // and the data it affects
        float _get_random_number_for_poke_data(SimulationPokeData raw_poke_data, int seed = 0)
        {
            float sum = seed;
            for (uint i = 0; i < 9; i++) sum += raw_poke_data[i];
            float mixedValue = sum * seed % (seed + 1);
            return mixedValue;
        }

        // This function determines whether a field is active for a given field index
        int _poking_active_for_field(int poke_mask, int global_field_index)
        {
            return (poke_mask & 1 << global_field_index) != 0 ? 1 : 0;
        }

        float _poking_profile(PokeApplicationCache poke_application_data)
        {
            float r = poke_application_data.normalized_distance_from_poking_sweep;
            return exp(-r * r);
        }

        void _fermion_state(PokeApplicationCache poke_application_data, out FermionFieldState new_fermion_state)
        {
            float mass = 1; // since a random field is chosen, the effective mass involved in the fermion state construction would be hardcoded
            float3 spin_vector = poke_application_data.sweep_delta;
            spin_vector.z = 1;
            DiracFormalism::construct_spin_state(normalize(spin_vector), poke_application_data.sweep_delta, mass, new_fermion_state);
        }

        float4 _gauge_vector(PokeApplicationCache poke_application_data)
        {
            float4 gauge_vector = float4(1, poke_application_data.distance_vector_to_poke_sweep);
            return normalize(gauge_vector);
        }

        // Apply a poke to the fermion fields at a given position given its poke data cache
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _apply_poke_to_fermion_fields(float3 position, PokeApplicationCache poke_application_data)
        {
            int number_of_poke_participating_fermion_fields = 0;
            for (int i = 0; i < FERMION_FIELDS_COUNT; i++) number_of_poke_participating_fermion_fields += _poking_active_for_field(poke_application_data.poke_mask, i);
            if (number_of_poke_participating_fermion_fields == 0) return;
            float poke_strength_at_position = poke_application_data.poking_strength * _poking_profile(poke_application_data);
            FermionFieldState new_fermion_state;
            _fermion_state(poke_application_data, new_fermion_state);
            for (uint i = 0; i < 5; i++)
            {
                // Obtain a random field index for the poke data - associated with a given unique raw poke data (ensuring all points affected by the same poke affect the same field)
                float randomly_chosen_participating_field = round(_get_random_number_for_poke_data(poke_application_data.raw_poke_data, i + 1)) % number_of_poke_participating_fermion_fields + 1;
                uint random_field_index;
                for (random_field_index = 0; random_field_index < FERMION_FIELDS_COUNT; random_field_index++)
                {
                    randomly_chosen_participating_field -= _poking_active_for_field(poke_application_data.poke_mask, random_field_index);
                    if (randomly_chosen_participating_field <= 0) break;
                }
                float field_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, random_field_index);
                FermionFieldState crnt_field_state = crnt_fermions_lattice_buffer[field_buffer_index];
                FermionFieldState prev_field_state = prev_fermions_lattice_buffer[field_buffer_index];
                float field_norm_sqrd = FermionFieldStateMath::norm_sqrd(crnt_field_state);
                FermionFieldState added_field_state;
                FermionFieldStateMath::rscl(new_fermion_state, poke_strength_at_position / (1 + field_norm_sqrd), added_field_state);
                FermionFieldStateMath::sum(crnt_field_state, added_field_state, crnt_field_state);
                FermionFieldStateMath::sum(prev_field_state, added_field_state, prev_field_state);
                crnt_fermions_lattice_buffer[field_buffer_index] = crnt_field_state;
                prev_fermions_lattice_buffer[field_buffer_index] = prev_field_state;
            }
        }

        // Apply a poke to the gauge fields at a given position given its poke data cache
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _apply_poke_to_gauge_fields(float3 position, PokeApplicationCache poke_application_data)
        {
            float poke_strength_at_position = poke_application_data.poking_strength * _poking_profile(poke_application_data);
            float4 potential_addition = _gauge_vector(poke_application_data);
            uint gauge_lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack crnt_potentials_pack = crnt_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack prev_potentials_pack = prev_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack added_gauge_state;
            for (uint i = 0; i < 12; i++) added_gauge_state[i] = poke_strength_at_position * potential_addition / (1 + length(crnt_potentials_pack[i]));
            GaugeSymmetriesVectorPackMath::sum(crnt_potentials_pack, added_gauge_state, crnt_potentials_pack);
            GaugeSymmetriesVectorPackMath::sum(prev_potentials_pack, added_gauge_state, prev_potentials_pack);
            crnt_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] = crnt_potentials_pack;
            prev_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] = prev_potentials_pack;
        }

        // Process a single poke at a given position
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void process_poke(float3 position, SimulationPokeData raw_poke_data)
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
        void process_pokes(float3 position)
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
