#ifndef FIELD_DENOISING
#define FIELD_DENOISING

#include "../ops/simulation_data_ops.hlsl"
#include "../ops/fermion_field_state_ops.hlsl"
#include "../ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../math/fermion_field_state_math.hlsl"


/// This namespace implements functions that provide field Denoising capabilities.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FieldDenoising
{
    // Compute the bilateral weight for a specified center fermion field state, a neighboring fermion field state, their offset and
    // the spatial and range standard deviations
    float _fermion_bilateral_weight(FermionFieldState center_state, FermionFieldState neighbor_state, float3 offset, float spatial_std, float range_std)
    {
        float spatial_weight = exp(-dot(offset, offset) / (2 * spatial_std * spatial_std));
        FermionFieldState state_difference;
        FermionFieldStateMath::sub(neighbor_state, center_state, state_difference);
        float difference_magnitude_sqrd = FermionFieldStateMath::norm_sqrd(state_difference);
        float range_weight = exp(-difference_magnitude_sqrd / (2 * range_std * range_std));
        return spatial_weight * range_weight;
    }

    // Compute the bilateral weight for a specified center gauge field states (4-vectors), a neighboring gauge field state, their offset and
    // the spatial and range standard deviations
    float _gauge_bilateral_weight(float4 center_state, float4 neighboring_state, float3 offset, float spatial_std, float range_std)
    {
        float spatial_weight = exp(-dot(offset, offset) / (2 * spatial_std * spatial_std));
        float4 state_difference = center_state - neighboring_state;
        float difference_magnitude_sqrd = dot(state_difference, state_difference);
        float range_weight = exp(-difference_magnitude_sqrd / (2 * range_std * range_std));
        return spatial_weight * range_weight;
    }

    // This function is used to denoise a fermion field with a specified field index at a specified position using a bilateral filter
    // algorithm with specified spatial and range standard deviations from a specified source fermion lattice buffer to a specified
    // target one.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void bilateral_denoise_fermion_state(float3 position, uint field_index, float spatial_std, float range_std, FermionLatticeBuffer source_lattice_buffer, FermionLatticeBuffer target_lattice_buffer)
    {
        uint center_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
        FermionFieldState fermion_state;
        FermionFieldStateOps::empty(fermion_state);
        FermionFieldState center_state = source_lattice_buffer[center_index];
        float total_weight = 0;
        for (int x = -1; x <= 1; x++)
        for (int y = -1; y <= 1; y++)
        for (int z = -1; z <= 1; z++)
        {
            float3 offset = float3(x, y, z);
            uint neighbor_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, field_index);
            FermionFieldState neighbor = source_lattice_buffer[neighbor_index];
            float weight = _fermion_bilateral_weight(center_state, neighbor, offset, spatial_std, range_std);
            total_weight += weight;
            FermionFieldState weighted;
            FermionFieldStateMath::rscl(neighbor, weight, weighted);
            FermionFieldStateMath::sum(fermion_state, weighted, fermion_state);
        }
        FermionFieldStateMath::rscl(fermion_state, 1.0 / total_weight, fermion_state);
        target_lattice_buffer[center_index] = fermion_state;
    }

    // This function is used to denoise all fermion fields at a specified position using a bilateral filter algorithm with specified spatial
    // and range standard deviations from a specified source fermion lattice buffer to a specified target one.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void bilateral_denoise_fermion_fields(float3 position, float spatial_std, float range_std, FermionLatticeBuffer source_lattice_buffer, FermionLatticeBuffer target_lattice_buffer)
    {
        for (uint field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++) bilateral_denoise_fermion_state(position, field_index, spatial_std, range_std, source_lattice_buffer, target_lattice_buffer);
    }

    // This function is used to denoise a gauge state with a specified symmetry index at a specified position using a bilateral filter
    // algorithm with specified spatial and range standard deviations in a specified gauge lattice buffer
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void bilateral_denoise_gauge_state(float3 position, uint symmetry_index, float spatial_std, float range_std, GaugeLatticeBuffer source_lattice_buffer, GaugeLatticeBuffer target_lattice_buffer)
    {
        uint center_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        float4 gauge_state = float4(0, 0, 0, 0);
        GaugeSymmetriesVectorPack center_states = source_lattice_buffer[center_index];
        float4 center_state = center_states[symmetry_index];
        float total_weight = 0;
        for (int x = -1; x <= 1; x++)
        for (int y = -1; y <= 1; y++)
        for (int z = -1; z <= 1; z++)
        {
            float3 offset = float3(x, y, z);
            uint neighbor_index = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset);
            GaugeSymmetriesVectorPack neighboring_states = source_lattice_buffer[neighbor_index];
            float4 neighbor_state = neighboring_states[symmetry_index];
            float weight = _gauge_bilateral_weight(center_state, neighbor_state, offset, spatial_std, range_std);
            total_weight += weight;
            gauge_state += weight * neighbor_state;
        }
        gauge_state /= total_weight;
        target_lattice_buffer[center_index][symmetry_index] = gauge_state;
    }

    // This function is used to denoise all gauge fields at a specified position using a bilateral filter algorithm with specified spatial
    // and range standard deviations in a specified gauge lattice buffer
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void bilateral_denoise_gauge_fields(float3 position, float spatial_std, float range_std, GaugeLatticeBuffer source_lattice_buffer, GaugeLatticeBuffer target_lattice_buffer)
    {
        for (uint symmetry_index = 0; symmetry_index < FERMION_FIELDS_COUNT; symmetry_index++) bilateral_denoise_gauge_state(position, symmetry_index, spatial_std, range_std, source_lattice_buffer, target_lattice_buffer);
    }
}

#endif
