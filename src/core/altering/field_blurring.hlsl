#ifndef FIELD_BLURING
#define FIELD_BLURING

#include "../ops/simulation_data_ops.hlsl"
#include "../ops/fermion_field_state_ops.hlsl"
#include "../ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../math/gauge_symmetries_vector_pack_math.hlsl"
#include "../math/fermion_field_state_math.hlsl"


/// This namespace implements functions that provide field blurring capabilities.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace FieldBlurring
{
    // Compute the Gaussian weight for a given offset and sigma (blur radius)
    float gaussian_weight(int x, int y, int z, float sigma)
    {
        float r2 = float(x * x + y * y + z * z);
        float twc_sigma_sqrd = 2.0 * sigma * sigma;
        float coeff = 1.0 / pow(3.14159 * twc_sigma_sqrd, 1.5);
        return coeff * exp(-r2 / twc_sigma_sqrd);
    }

    // Blur the fermion fields at a given position with a specified kernel radius and standard deviation
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void blur_fermion_fields(float3 position, int kernel_radius, float standard_deviation, FermionLatticeBuffer fermion_lattice_buffer)
    {
        for (uint field_index = 0; field_index < 8; field_index++)
        {
            uint center_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
            FermionFieldState fermion_state;
            FermionFieldStateOps::empty(fermion_state);
            float total_weight = 0;
            for (int x = -kernel_radius; x <= kernel_radius; x++)
            for (int y = -kernel_radius; y <= kernel_radius; y++)
            for (int z = -kernel_radius; z <= kernel_radius; z++)
            {
                float3 offset = float3(x, y, z);
                float weight = gaussian_weight(x, y, z, standard_deviation);
                total_weight += weight;
                uint neighbor_index = SimulationDataOps::get_fermion_lattice_buffer_index(position + offset, field_index);
                FermionFieldState neighbor = fermion_lattice_buffer[neighbor_index];
                FermionFieldState weighted;
                FermionFieldStateMath::rscl(neighbor, weight, weighted);
                FermionFieldStateMath::sum(fermion_state, weighted, fermion_state);
            }
            FermionFieldStateMath::rscl(fermion_state, 1.0 / total_weight, fermion_state);
            fermion_lattice_buffer[center_index] = fermion_state;
        }
    }

    // Blur the gauge fields at a given position with a specified kernel radius and standard deviation
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    // • Writes directly to the simulation's lattice buffers
    void blur_gauge_fields(float3 position, int kernel_radius, float standard_deviation, GaugeLatticeBuffer gauge_lattice_buffer)
    {
        uint center_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack state;
        GaugeSymmetriesVectorPackOps::empty(state);
        float total_weight = 0;
        for (int x = -kernel_radius; x <= kernel_radius; x++)
        for (int y = -kernel_radius; y <= kernel_radius; y++)
        for (int z = -kernel_radius; z <= kernel_radius; z++)
        {
            float3 offset = float3(x, y, z);
            float weight = gaussian_weight(x, y, z, standard_deviation);
            total_weight += weight;
            uint neighbor_index = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset);
            GaugeSymmetriesVectorPack neighbor = gauge_lattice_buffer[neighbor_index];
            GaugeSymmetriesVectorPack weighted;
            GaugeSymmetriesVectorPackMath::scl(neighbor, weight, weighted);
            GaugeSymmetriesVectorPackMath::sum(state, weighted, state);
        }
        GaugeSymmetriesVectorPackMath::scl(state, 1.0 / total_weight, state);
        gauge_lattice_buffer[center_index] = state;
    }
}

#endif
