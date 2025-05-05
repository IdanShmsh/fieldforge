#ifndef ACTIVITY_DEPENDENT_FIELD_BLURRING
#define ACTIVITY_DEPENDENT_FIELD_BLURRING

#include "../../core/analysis/fermion_energy_computations.hlsl"
#include "../../core/analysis/gauge_energy_computations.hlsl"
#include "../../core/altering/field_blurring.hlsl"

#ifndef BLURRING_KERNEL_RADIUS
#define BLURRING_KERNEL_RADIUS 1
#endif

namespace GuardingRails
{
    /// Implementation of an activity-dependent field blurring.
    /// Allows performing field blurring with a radius directly proportional on the local activity of the fields.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace ActivityDependentEnergyDissipation
    {
        // Compute the energy density of all fields in the simulation at a given point
        float _compute_energy_density(float3 position)
        {
            float energy_density = 0;
            energy_density += FermionEnergyComputations::compute_energy_density(position);
            energy_density += GaugeEnergyComputations::compute_energy_density(position) / 8;
            return energy_density;
        }

        // Apply an energy density-dependent blurring to the fields at a given position
        // with a specified energy scale
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void energy_density_dependent_blurring(float3 position, float energy_scale)
        {
            float energy_density = _compute_energy_density(position);
            // This is a simple hyperbola : https://www.desmos.com/calculator/fuuc0ethl9
            float blurring_radius = sqrt(1 + pow(energy_density / energy_scale, 2)) - 1;
            if (blurring_radius < 1) return;
            int kernel_radius = max((int)blurring_radius, 1);
            FieldBlurring::blur_fermion_fields(position, kernel_radius, blurring_radius, crnt_fermions_lattice_buffer);
            FieldBlurring::blur_gauge_fields(position, kernel_radius, blurring_radius, crnt_gauge_potentials_lattice_buffer);
            FieldBlurring::blur_gauge_fields(position, kernel_radius, blurring_radius, crnt_electric_strengths_lattice_buffer);
            FieldBlurring::blur_gauge_fields(position, kernel_radius, blurring_radius, crnt_magnetic_strengths_lattice_buffer);
        }
    }
}

#endif
