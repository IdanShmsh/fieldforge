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
            float4 gauge_vector = float4(1, poke_application_data.distance_vector_to_poke_sweep + poke_application_data.sweep_delta);
            return normalize(gauge_vector);
        }

        float4 _electric_field_vector(PokeApplicationCache poke_application_data)
        {
            float4 field_vector = float4(1, poke_application_data.distance_vector_to_poke_sweep);
            return normalize(field_vector);
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
            const float TWO_PI = 6.28318530718f;

            // Unit-consistent finite-segment current (3D capsule):
            // J_vol ≈ (q / (2π σ^2 L Δt)) * t_hat * exp(-r^2/(2σ^2))
            float sweep_length = max(length(poke_application_data.sweep_delta), 1e-6);
            float3 normalized_sweep = poke_application_data.sweep_delta / sweep_length;
            float poking_radius = max(poke_application_data.poking_radius, 1e-6);
            float poking_radius_sqrd = poking_radius * poking_radius;
            float distance_from_poking_sweep_sqrd = dot(poke_application_data.distance_vector_to_poke_sweep, poke_application_data.distance_vector_to_poke_sweep);
            float tube_profile = exp(-distance_from_poking_sweep_sqrd / (2.0f * poking_radius_sqrd));
            float temporal_unit = max(simulation_temporal_unit, 1e-6);
            float volumetric_current_normalization = poke_application_data.poking_strength / max(TWO_PI * poking_radius_sqrd * sweep_length * temporal_unit, 1e-6);
            float3 current_density = volumetric_current_normalization * normalized_sweep * tube_profile;

            float3 electric_field_increment = -(2.0f * temporal_unit) * current_density;

            float3 tube_profile_gradient = -(poke_application_data.distance_vector_to_poke_sweep / poking_radius_sqrd) * tube_profile;
            float3 magnetic_field_increment = (2.0f * temporal_unit) * cross(normalized_sweep, tube_profile_gradient);

            // Add a longitudinal (divergent) electric field so that div E ≈ rho for a Gaussian tube
            // rho_vol = (poking_strength / (2π * poking_radius_sqrd * sweep_length)) * tube_profile
            float rho0 = poke_application_data.poking_strength / max(TWO_PI * poking_radius_sqrd * sweep_length, 1e-6);
            float r = max(poke_application_data.distance_from_poking_sweep, 1e-6);
            float one_minus_exp = 1.0f - exp(-distance_from_poking_sweep_sqrd / (2.0f * poking_radius_sqrd));
            float radial_E_magnitude = (rho0 * poking_radius_sqrd / r) * one_minus_exp;
            float3 radial_direction = poke_application_data.distance_vector_to_poke_sweep / r;
            float3 divergent_electric_increment = radial_E_magnitude * radial_direction;
            electric_field_increment += divergent_electric_increment;

            uint gauge_lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack crnt_electric_pack = crnt_electric_strengths_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack prev_electric_pack = prev_electric_strengths_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack crnt_magnetic_pack = crnt_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack prev_magnetic_pack = prev_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack added_magnetic_state, added_electric_state;
            [unroll]
            for (uint i = 0; i < 12; i++)
            {
                const int active = _poking_active_for_field(poke_application_data.poke_mask, i + 8);
                float4 dE4 = float4(0.0f, electric_field_increment.xyz);
                float4 dB4 = float4(0.0f, magnetic_field_increment.xyz);
                float  denomE = 1.0f + length(crnt_electric_pack[i]);
                float  denomB = 1.0f + length(crnt_magnetic_pack[i]);
                added_electric_state[i] = active * (dE4 / denomE);
                added_magnetic_state[i] = active * (dB4 / denomB);
            }

            GaugeSymmetriesVectorPackMath::sum(crnt_electric_pack,  added_electric_state,  crnt_electric_pack);
            GaugeSymmetriesVectorPackMath::sum(prev_electric_pack,  added_electric_state,  prev_electric_pack);
            GaugeSymmetriesVectorPackMath::sum(crnt_magnetic_pack,  added_magnetic_state,  crnt_magnetic_pack);
            GaugeSymmetriesVectorPackMath::sum(prev_magnetic_pack,  added_magnetic_state,  prev_magnetic_pack);

            crnt_electric_strengths_lattice_buffer[gauge_lattice_buffer_index]  = crnt_electric_pack;
            prev_electric_strengths_lattice_buffer[gauge_lattice_buffer_index]  = prev_electric_pack;
            crnt_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index]  = crnt_magnetic_pack;
            prev_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index]  = prev_magnetic_pack;
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
