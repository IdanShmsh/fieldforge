#ifndef GUARDRAILS_PASSIVE_FIELD_BLURRING
#define GUARDRAILS_PASSIVE_FIELD_BLURRING

#include "../../core/altering/field_blurring.hlsl"


namespace Guardrails
{
    /// Implementation of passive field blurring capabilities.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace PassiveFieldBlurring
    {
        // Blur the fermion fields at a given position with a specified kernel radius and standard deviation
        // from a specified source fermion lattice buffer to a specified target one.
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void blur_fermion_fields(float3 position, float standard_deviation, FermionLatticeBuffer source_lattice_buffer, FermionLatticeBuffer target_lattice_buffer)
        {
            FieldBlurring::blur_fermion_fields_3x3x3(position, standard_deviation, source_lattice_buffer, target_lattice_buffer);
        }

        // Blur the gauge fields at a given position with a specified kernel radius and standard deviation
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void blur_gauge_fields(float3 position, float standard_deviation, GaugeLatticeBuffer source_lattice_buffer, GaugeLatticeBuffer target_lattice_buffer)
        {
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, source_lattice_buffer, target_lattice_buffer);
        }
    }
}

#endif
