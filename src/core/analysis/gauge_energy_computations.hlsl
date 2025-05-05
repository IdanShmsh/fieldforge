#ifndef GAUGE_ENERGY_COMPUTATIONS
#define GAUGE_ENERGY_COMPUTATIONS

#include "../ops/simulation_data_ops.hlsl"
#include "../formalisms/yang_mills_formalism.hlsl"
#include "gauge_field_differentials.hlsl"

/// This namespace implements functions used to compute the energy density of gauge fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace GaugeEnergyComputations
{
    // Compute the total energy density of all gauge fields given their field strength tensor
    float compute_energy_density(GaugeFieldStrength field_strength_tensor) {
        float total_energy = 0;
        for (uint a = 0; a < 12; a++) for (uint m = 0; m < 4; m++) for (uint n = 0; n < 4; n++) total_energy += dot(field_strength_tensor[a][m][n], field_strength_tensor[a][m][n]); // unroll
        total_energy /= 2;
        return total_energy;
    }

    // Compute the energy densities of all gauge fields given their field strength tensor
    void compute_energy_density(GaugeFieldStrength field_strength_tensor, out float energy_densities[12]) {
        for (uint a = 0; a < 12; a++) {
            energy_densities[a] = 0;
            for (uint m = 0; m < 4; m++) for (uint n = 0; n < 4; n++) energy_densities[a] += dot(field_strength_tensor[a][m][n], field_strength_tensor[a][m][n]); // unroll
            energy_densities[a] /= 2;
        }
    }

    // Compute the total energy density of all gauge fields given their electric and magnetic field strengths
    float compute_energy_density(GaugeSymmetriesVectorPack electric_field_strength, GaugeSymmetriesVectorPack magnetic_field_strength) {
        float total_energy = 0;
        total_energy += GaugeSymmetriesVectorPackMath::dot(electric_field_strength, electric_field_strength);
        total_energy += GaugeSymmetriesVectorPackMath::dot(magnetic_field_strength, magnetic_field_strength);
        return total_energy;
    }

    // Compute the energy density of all gauge fields at a specified simulation location
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    float compute_energy_density(float3 position) {
        uint lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
        GaugeSymmetriesVectorPack electric_strengths = crnt_electric_strengths_lattice_buffer[lattice_buffer_index];
        GaugeSymmetriesVectorPack magnetic_strengths = crnt_magnetic_strengths_lattice_buffer[lattice_buffer_index];
        return compute_energy_density(electric_strengths, magnetic_strengths);
    }
}

#endif
