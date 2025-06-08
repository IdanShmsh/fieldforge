#ifndef ACTIVITY_DEPENDENT_SCALING
#define ACTIVITY_DEPENDENT_SCALING

#include "../../core/analysis/fermion_energy_computations.hlsl"
#include "../../core/analysis/gauge_energy_computations.hlsl"
#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/math/fermion_field_state_math.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"

#ifndef BLURRING_KERNEL_RADIUS
#define BLURRING_KERNEL_RADIUS 1
#endif

namespace Guardrails
{
    /// Implementation of an activity-dependent energy dissipation.
    /// Allows performing energy dissipation in the simulation with aggressiveness directly proportional on the local
    /// activity of the fields.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace ActivityDependentScaling
    {
        // Apply an energy density-dependent
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void fermion_energy_density_dependent_scaling(float3 position, float energy_scale, FermionLatticeBuffer lattice_buffer)
        {
            float energy_density = abs(FermionEnergyComputations::compute_energy_density(position));
            // This is a simple hyperbola : https://www.desmos.com/calculator/fuuc0ethl9
            float scale_factor = 1.0 / (energy_density / energy_scale + 1.0);
            for (uint field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
            {
                uint lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
                FermionFieldState fermion_state = lattice_buffer[lattice_buffer_index];
                FermionFieldStateMath::rscl(fermion_state, scale_factor, fermion_state);
                lattice_buffer[lattice_buffer_index] = fermion_state;
            }
        }

        // Apply an energy density-dependent
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void gauge_energy_density_dependent_scaling(float3 position, float energy_scale, GaugeLatticeBuffer lattice_buffer)
        {
            float energy_density = abs(GaugeEnergyComputations::compute_energy_density(position));
            // This is a simple hyperbola : https://www.desmos.com/calculator/fuuc0ethl9
            float scale_factor = 1.0 / (energy_density / energy_scale + 1.0);
            uint lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack gauge_vectors_pack = lattice_buffer[lattice_buffer_index];
            GaugeSymmetriesVectorPackMath::scl(gauge_vectors_pack, scale_factor, gauge_vectors_pack);
            lattice_buffer[lattice_buffer_index] = gauge_vectors_pack;
        }
    }
}

#endif
