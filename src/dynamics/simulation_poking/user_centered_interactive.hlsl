#ifndef SIMULATION_POKES_PROCESSING_USER_CENTERED_INTERACTIVE
#define SIMULATION_POKES_PROCESSING_USER_CENTERED_INTERACTIVE

#include "../../core/formalisms/dirac_formalism.hlsl"
#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/structures/simulation_poke_data.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../../core/simulation_globals.hlsl"


// TODO - this needs to be modified: made concise, optimized, and polished.
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

        // Apply a poke to the fermion fields at a given position given its poke data cache
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _apply_poke_to_fermion_fields(float3 position, PokeApplicationCache poke_application_data)
        {
            int number_of_poke_participating_fermion_fields = 0;
            // TODO - this can be done much more effectively / if even
            for (int i = 0; i < 8; i++) number_of_poke_participating_fermion_fields += _poking_active_for_field(poke_application_data.poke_mask, i);

            if (number_of_poke_participating_fermion_fields == 0) return;

            // https://www.desmos.com/3d/qd6dwwgmwv - TODO - polish this
            float poke_strength_at_position = 0.25 * exp(-pow(8 * (poke_application_data.normalized_distance_from_poking_sweep - 1) , 2)) + exp(-pow(poke_application_data.normalized_distance_from_poking_sweep / 1.5, 2));

            // Construct an appropriate spin state associated with the sweep
            float mass = 1; // since a random field is chosen, the effective mass involved in the fermion state construction would be hardcoded
            float3 spin_vector = poke_application_data.sweep_delta;
            spin_vector.z = 1;
            FermionFieldState new_fermion_state;
            DiracFormalism::construct_spin_state(normalize(spin_vector), poke_application_data.sweep_delta, mass, new_fermion_state);

            // add the norm to 5 random fermion fields
            for (uint i = 0; i < 5; i++)
            {
                // Obtain a random field index for the poke data - associated with a given unique raw poke data (ensuring all points affected by the same poke affect the same field)
                float randomly_chosen_participating_field = round(_get_random_number_for_poke_data(poke_application_data.raw_poke_data, i + 1)) % number_of_poke_participating_fermion_fields + 1;
                // The field index given is transformed to an appropriate field index participating in the poke as specified by the mask
                uint random_field_index;
                for (random_field_index = 0; random_field_index < 8; random_field_index++)
                {
                    randomly_chosen_participating_field -= _poking_active_for_field(poke_application_data.poke_mask, random_field_index);
                    if (randomly_chosen_participating_field <= 0) break;
                }

                // Get the buffer index of the spinor field for the given position and field index
                float field_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, random_field_index);

                // Obtain the current state
                FermionFieldState crnt_field_state = crnt_fermions_lattice_buffer[field_buffer_index];
                FermionFieldState prev_field_state = prev_fermions_lattice_buffer[field_buffer_index];

                // Obtain the current state's norm
                float crnt_state_norm = FermionFieldStateMath::norm_sqrd(crnt_field_state);
                float prev_state_norm = FermionFieldStateMath::norm_sqrd(prev_field_state);

                // The effect the poke has in a position is proportional to the overall strength of the poke, the strength of the poke at the position, and inversely proportional to the current state's norm to prevent poking from blowing up the field
                float crnt_poke_effect_at_position = poke_strength_at_position * poke_application_data.poking_strength / (crnt_state_norm + 1);
                float prev_poke_effect_at_position = poke_strength_at_position * poke_application_data.poking_strength / (prev_state_norm + 1);

                FermionFieldState crnt_new_fermion_state, prev_new_fermion_state;

                // The effect is implemented by scaling the spin state added to the field accordingly
                FermionFieldStateMath::rscl(new_fermion_state, crnt_poke_effect_at_position, crnt_new_fermion_state);
                FermionFieldStateMath::rscl(new_fermion_state, prev_poke_effect_at_position, prev_new_fermion_state);

                // Interpolate between the current and the spin state
                FermionFieldStateMath::sum(crnt_field_state, crnt_new_fermion_state, crnt_new_fermion_state);
                FermionFieldStateMath::sum(prev_field_state, prev_new_fermion_state, prev_new_fermion_state);

                // Write the new spinor state to the buffer
                crnt_fermions_lattice_buffer[field_buffer_index] = crnt_new_fermion_state;
                prev_fermions_lattice_buffer[field_buffer_index] = prev_new_fermion_state;
            }
        }

        // Apply a poke to the gauge fields at a given position given its poke data cache
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _apply_poke_to_gauge_fields(float3 position, PokeApplicationCache poke_application_data)
        {
            // https://www.desmos.com/3d/qd6dwwgmwv
            float poke_strength_at_position = exp(-pow(2 * poke_application_data.normalized_distance_from_poking_sweep, 2));

            // Construct a gauge potential along the sweep direction
            float4 potential_addition = float4(1, 0, 0, 0);
            potential_addition.yzw = poke_application_data.sweep_delta;
            /// By the temporal component being >0, this normalizes the sweep delta while retaining an increasing relation between the sweep and the spatial spin state's sizes
            normalize(potential_addition);

            // Get the buffer index of the gauge field state
            uint gauge_lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);

            // Obtain the current state
            GaugeSymmetriesVectorPack crnt_potentials_pack = crnt_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index];
            GaugeSymmetriesVectorPack prev_potentials_pack = prev_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index];

            GaugeSymmetriesVectorPack masked_crnt_potentials_pack, masked_prev_potentials_pack;
            GaugeSymmetriesVectorPackOps::apply_mask(poke_application_data.poke_mask,crnt_potentials_pack, masked_crnt_potentials_pack);
            GaugeSymmetriesVectorPackOps::apply_mask(poke_application_data.poke_mask,prev_potentials_pack, masked_prev_potentials_pack);

            // Obtain the current state's norm
            float crnt_gauge_field_norm = GaugeSymmetriesVectorPackMath::norm_sqrd(masked_crnt_potentials_pack);
            float prev_gauge_field_norm = GaugeSymmetriesVectorPackMath::norm_sqrd(masked_prev_potentials_pack);

            // Compute a phase along the swipe direction
            float phase_factor = cos(dot(position - poke_application_data.poking_position, poke_application_data.sweep_delta) / (dot(poke_application_data.sweep_delta, poke_application_data.sweep_delta) + 1));

            // The effect the poke has in a position is proportional to the overall strength of the poke, the strength of the poke at the position, and inversely proportional to the current state's norm to implement norm limitation
            float crnt_poke_effect_at_position = poke_strength_at_position * phase_factor * poke_application_data.poking_strength / (crnt_gauge_field_norm + 1);
            float prev_poke_effect_at_position = poke_strength_at_position * phase_factor * poke_application_data.poking_strength / (prev_gauge_field_norm + 1);

            // That effect is implemented by scaling the gauge potential added to the field accordingly
            float4 crntGaugeChange = potential_addition * crnt_poke_effect_at_position;
            float4 prevGaugeChange = potential_addition * prev_poke_effect_at_position;

            GaugeSymmetriesVectorPackOps::apply_mask(poke_application_data.poke_mask,crnt_potentials_pack, masked_crnt_potentials_pack);
            GaugeSymmetriesVectorPackOps::apply_mask(poke_application_data.poke_mask,prev_potentials_pack, masked_prev_potentials_pack);

            // Initialize a new gauge field state
            GaugeSymmetriesVectorPack crntNewGaugeState = crnt_potentials_pack;
            GaugeSymmetriesVectorPack prevNewGaugeState = prev_potentials_pack;

            // Add the gauge potential to the gauge field state (with the mask incorporated)
            for (int a = 0; a < 12; a++)
            {
                crntNewGaugeState[a] = crnt_potentials_pack[a] + _poking_active_for_field(poke_application_data.poke_mask, 8 + a) * crntGaugeChange;
                prevNewGaugeState[a] = prev_potentials_pack[a] + _poking_active_for_field(poke_application_data.poke_mask, 8 + a) * prevGaugeChange;
            }

            // Write the new gauge field state to the buffer
            crnt_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] = crntNewGaugeState;
            prev_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] = prevNewGaugeState;
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
