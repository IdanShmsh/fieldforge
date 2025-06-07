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
        // Apply an energy density-dependent blurring to the fermion fields at a given position
        // with a specified energy scale, from a specified source fermion lattice buffer to a specified target one.
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void fermions_energy_density_dependent_blurring(float3 position, float energy_scale, float radius_cap, FermionLatticeBuffer source_lattice_buffer, FermionLatticeBuffer target_lattice_buffer)
        {
            float energy_density = FermionEnergyComputations::compute_energy_density(position) / energy_scale;
            float standard_deviation = radius_cap * (1 - exp(-energy_density * energy_density));
            FieldBlurring::blur_fermion_fields_3x3x3(position, standard_deviation, source_lattice_buffer, target_lattice_buffer);
        }

        // Apply an energy density-dependent blurring to the gauge fields at a given position
        // with a specified energy scale, from a specified source gauge lattice buffer to a specified target one.
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void gauge_energy_density_dependent_blurring(float3 position, float energy_scale, float radius_cap, GaugeLatticeBuffer source_lattice_buffer, GaugeLatticeBuffer target_lattice_buffer)
        {
            float energy_density = FermionEnergyComputations::compute_energy_density(position) / energy_scale;
            float standard_deviation = radius_cap * (1 - exp(-energy_density * energy_density));
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, source_lattice_buffer, target_lattice_buffer);
        }
    }
}

#endif
