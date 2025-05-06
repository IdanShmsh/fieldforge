#ifndef ACTIVITY_DEPENDENT_ENERGY_DISSIPATION
#define ACTIVITY_DEPENDENT_ENERGY_DISSIPATION

#include "../../core/analysis/fermion_energy_computations.hlsl"
#include "../../core/analysis/gauge_energy_computations.hlsl"
#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/math/fermion_field_state_math.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"

#ifndef BLURRING_KERNEL_RADIUS
#define BLURRING_KERNEL_RADIUS 1
#endif

namespace GuardingRails
{
    /// Implementation of an activity-dependent energy dissipation.
    /// Allows performing energy dissipation in the simulation with aggressiveness directly proportional on the local
    /// activity of the fields.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace ActivityDependentEnergyDissipation
    {
        // This function is used to scale the fermion fields at a given position by a scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _scale_fermion_fields(float3 position, float scale_factor, FermionLatticeBuffer fermion_lattice_buffer)
        {
            for (uint field_index = 0; field_index < 8; field_index++)
            {
                uint lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
                FermionFieldState fermion_state = fermion_lattice_buffer[lattice_buffer_index];
                FermionFieldStateMath::rscl(fermion_state, scale_factor, fermion_state);
                fermion_lattice_buffer[lattice_buffer_index] = fermion_state;
            }
        }

        // This function is used to scale the gauge fields at a given position by a scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _scale_gauge_fields(float3 position, float scale_factor, GaugeLatticeBuffer gauge_lattice_buffer)
        {
            uint lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPack gauge_vectors_pack = gauge_lattice_buffer[lattice_buffer_index];
            GaugeSymmetriesVectorPackMath::scl(gauge_vectors_pack, scale_factor, gauge_vectors_pack);
            gauge_lattice_buffer[lattice_buffer_index] = gauge_vectors_pack;
        }

        // Compute the energy density of all fields in the simulation at a given point
        float _compute_energy_density(float3 position)
        {
            float energy_density = 0;
            energy_density += FermionEnergyComputations::compute_energy_density(position);
            energy_density += GaugeEnergyComputations::compute_energy_density(position) / 8;
            return energy_density;
        }

        // Apply an energy density-dependent
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void energy_density_dependent_scaling(float3 position, float energy_scale)
        {
            float energy_density = _compute_energy_density(position);
            // This is a simple hyperbola : https://www.desmos.com/calculator/fuuc0ethl9
            float scale_factor = 1.0 / (energy_density / energy_scale + 1.0);
            _scale_fermion_fields(position, scale_factor, crnt_fermions_lattice_buffer);
            _scale_gauge_fields(position, scale_factor, crnt_gauge_potentials_lattice_buffer);
            _scale_gauge_fields(position, scale_factor, crnt_electric_strengths_lattice_buffer);
            _scale_gauge_fields(position, scale_factor, crnt_magnetic_strengths_lattice_buffer);
        }
    }
}

#endif
