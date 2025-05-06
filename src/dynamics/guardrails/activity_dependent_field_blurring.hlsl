#ifndef ACTIVITY_DEPENDENT_FIELD_BLURRING
#define ACTIVITY_DEPENDENT_FIELD_BLURRING

#include "../../core/analysis/fermion_energy_computations.hlsl"
#include "../../core/analysis/gauge_energy_computations.hlsl"
#include "../../core/altering/field_blurring.hlsl"

#ifndef BLURRING_KERNEL_RADIUS
#define BLURRING_KERNEL_RADIUS 1
#endif

namespace Guardrails
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
        void energy_density_dependent_blurring(float3 position, float energy_scale, float radius_cap)
        {
            float energy_density = _compute_energy_density(position) / energy_scale;
            // TODO: provide visualization
            float standard_deviation = radius_cap * (1 - exp(-energy_density * energy_density));
            FieldBlurring::blur_fermion_fields_3x3x3(position, standard_deviation, crnt_fermions_lattice_buffer);
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, crnt_gauge_potentials_lattice_buffer);
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, crnt_electric_strengths_lattice_buffer);
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, crnt_magnetic_strengths_lattice_buffer);
        }
    }
}

#endif
