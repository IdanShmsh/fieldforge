#ifndef FIELD_BLURRING
#define FIELD_BLURRING

#include "../ops/simulation_data_ops.hlsl"
#include "../ops/fermion_field_state_ops.hlsl"
#include "../ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../math/gauge_symmetries_vector_pack_math.hlsl"
#include "../math/fermion_field_state_math.hlsl"


/// This namespace implements functions that provide field blurring capabilities.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FieldBlurring
{
    // Blur the fermion fields at a given position with a specified kernel radius and standard deviation from a specified
    // fermion lattice buffer to a specified target fermion lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void blur_fermion_fields_3x3x3(float3 position, float standard_deviation, FermionLatticeBuffer source_lattice_buffer, FermionLatticeBuffer target_lattice_buffer)
    {
        for (uint field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
        {
            uint center_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
            FermionFieldState fermion_state;
            FermionFieldStateOps::empty(fermion_state);
            float total_weight = 0;
            for (int x = -1; x <= 1; x++)
            for (int y = -1; y <= 1; y++)
            for (int z = -1; z <= 1; z++)
            {
                float3 offset = float3(x, y, z);
                float weight = CommonMath::gaussian(offset, standard_deviation);
                total_weight += weight;
                uint neighbor_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, field_index);
                FermionFieldState neighbor = source_lattice_buffer[neighbor_index];
                FermionFieldStateMath::rscl_sum(fermion_state, neighbor, 1, weight, fermion_state);
            }
            FermionFieldStateMath::rscl(fermion_state, 1.0 / total_weight, fermion_state);
            target_lattice_buffer[center_index] = fermion_state;
        }
    }

    // Blur the gauge fields at a given position with a specified kernel radius and standard deviation from a specified source gauge lattice buffer to a specified target one.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void blur_gauge_fields_3x3x3(float3 position, float standard_deviation, GaugeLatticeBuffer source_lattice_buffer, GaugeLatticeBuffer target_lattice_buffer)
    {
        uint center_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack state;
        GaugeSymmetriesVectorPackOps::empty(state);
        float total_weight = 0;
        for (int x = -1; x <= 1; x++)
        for (int y = -1; y <= 1; y++)
        for (int z = -1; z <= 1; z++)
        {
            float3 offset = float3(x, y, z);
            float weight = CommonMath::gaussian(offset, standard_deviation);
            total_weight += weight;
            uint neighbor_index = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset);
            GaugeSymmetriesVectorPack neighbor = source_lattice_buffer[neighbor_index];
            GaugeSymmetriesVectorPackMath::scl_sum(state, neighbor, 1, weight, state);
        }
        GaugeSymmetriesVectorPackMath::scl(state, 1.0 / total_weight, state);
        target_lattice_buffer[center_index] = state;
    }
}

#endif
