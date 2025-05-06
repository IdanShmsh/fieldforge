#ifndef GUARDRAILS_PASSIVE_SCALING_ENERGY_DISSIPATION
#define GUARDRAILS_PASSIVE_SCALING_ENERGY_DISSIPATION

#include "../../core/math/gauge_symmetries_vector_pack_math.hlsl"
#include "../../core/math/fermion_field_state_math.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"

namespace GuardingRails
{
    /// Implementation of passive energy dissipation capabilities.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace PassiveScalingEnergyDissipation
    {
        // This function is used to scale all fermion fields at a given position by a given scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void dissipate_spinor_fields_energy(float3 position, float scaling_factor)
        {
            for (uint field_index = 0; field_index < 8; field_index++)
            {
                if (!SimulationDataOps::is_fermion_field_active(field_index)) continue;
                uint bufferIndex = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
                FermionFieldStateMath::rscl(crnt_fermions_lattice_buffer[bufferIndex], scaling_factor, crnt_fermions_lattice_buffer[bufferIndex]);
            }
        }

        // This function is used to scale all gauge fields at a given position by a given scale factor
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void dissipate_gauge_fields_energy(float3 position, float scaling_factor)
        {
            uint bufferIndex = SimulationDataOps::get_gauge_lattice_buffer_index(position);
            GaugeSymmetriesVectorPackMath::scl(crnt_gauge_potentials_lattice_buffer[bufferIndex], scaling_factor, crnt_gauge_potentials_lattice_buffer[bufferIndex]);
            GaugeSymmetriesVectorPackMath::scl(crnt_electric_strengths_lattice_buffer[bufferIndex], scaling_factor, crnt_electric_strengths_lattice_buffer[bufferIndex]);
            GaugeSymmetriesVectorPackMath::scl(crnt_magnetic_strengths_lattice_buffer[bufferIndex], scaling_factor, crnt_magnetic_strengths_lattice_buffer[bufferIndex]);
        }

        // This function is used to dissipate energy from all fields at a given position
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        void dissipate_energy(float3 position, float energy_dissipation_factor)
        {
            float scaling_factor = 1 - energy_dissipation_factor;
            dissipate_spinor_fields_energy(position, scaling_factor);
            dissipate_gauge_fields_energy(position, scaling_factor);
        }
    }
}

#endif
