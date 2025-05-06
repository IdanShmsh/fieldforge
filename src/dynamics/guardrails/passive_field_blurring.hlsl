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
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void blur_fermion_fields(float3 position, float standard_deviation, FermionLatticeBuffer fermion_lattice_buffer)
        {
            FieldBlurring::blur_fermion_fields_3x3x3(position, standard_deviation, fermion_lattice_buffer);
        }

        // Blur the gauge fields at a given position with a specified kernel radius and standard deviation
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void blur_gauge_fields(float3 position, float standard_deviation, GaugeLatticeBuffer gauge_lattice_buffer)
        {
            FieldBlurring::blur_gauge_fields_3x3x3(position, standard_deviation, gauge_lattice_buffer);
        }
    }
}

#endif
