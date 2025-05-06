#ifndef GUARDRAILS_PASSIVE_FIELD_DENOISING
#define GUARDRAILS_PASSIVE_FIELD_DENOISING

#include "../../core/altering/field_denoising.hlsl"


namespace Guardrails
{
    /// Implementation of passive field denoising capabilities.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace PassiveFieldDenoising
    {
        // Denoise the fermion fields at a given position using a bilateral denoising algorithm with specified spacial
        // and range stds in a specified fermion lattice buffer
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void bilateral_denoise_fermion_fields(float3 position, float spatial_std, float range_std, FermionLatticeBuffer fermion_lattice_buffer)
        {
            FieldDenoising::bilateral_denoise_fermion_fields(position, spatial_std, range_std, fermion_lattice_buffer);
        }

        // Denoise the gauge fields at a given position using a bilateral denoising algorithm with specified spacial
        // and range stds in a specified gauge lattice buffer
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void bilateral_denoise_gauge_fields(float3 position, float spatial_std, float range_std, GaugeLatticeBuffer gauge_lattice_buffer)
        {
            FieldDenoising::bilateral_denoise_gauge_fields(position, spatial_std, range_std, gauge_lattice_buffer);
        }
    }
}

#endif
