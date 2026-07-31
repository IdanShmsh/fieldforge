#ifndef SIMULATION_POKES_PROCESSING
#define SIMULATION_POKES_PROCESSING

#include "../../core/structures/simulation_poke_data.hlsl"
#include "../../core/simulation_globals.hlsl"


// Shared building blocks for all poke-processing implementations. Anything living directly under the
// SimulationPokesProcessing namespace (rather than a specific implementation sub-namespace) is common to
// every poke strategy - the cached poke structure, its construction, the poke-data hash, and small
// field-mask helpers. Implementation sub-namespaces (UserCenteredInteractive, PhysicallyMeaningful, ...)
// include this file and build their strategy-specific physics on top of these.
namespace SimulationPokesProcessing
{
    // A structure of computed cached properties associated with a poke or necessary for its application
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

    // Returns a well-mixed 32-bit hash of the poke data and a seed - ensuring consistency between a poke
    // and the data it affects (the same poke always hashes the same way). Callers fold the hash into the
    // range they need with an integer modulo. Do that modulo on this uint, not after casting to half: a
    // half holds only ~11 mantissa bits, so casting the full hash first would round away the low-bit
    // entropy the modulo depends on.
    // NOTE: the loop is [loop], not [unroll] - this helper is inlined at many call sites inside other
    // loops, and unrolling it there makes the fxc optimizer hang while compiling the poke kernels.
    uint _get_random_number_for_poke_data(SimulationPokeData raw_poke_data, int seed = 0)
    {
        uint hash = 0x9E3779B9u ^ (uint)seed;
        [loop]
        for (uint poke_data_index = 0; poke_data_index < 9; poke_data_index++)
        {
            hash ^= (uint)raw_poke_data[poke_data_index];
            hash *= 0x85EBCA6Bu;
            hash ^= hash >> 13;
            hash *= 0xC2B2AE35u;
            hash ^= hash >> 16;
        }
        return hash;
    }

    // This function determines whether a field is active for a given field index
    int _poking_active_for_field(int poke_mask, int global_field_index)
    {
        return (poke_mask & 1 << global_field_index) != 0 ? 1 : 0;
    }
}

#endif
