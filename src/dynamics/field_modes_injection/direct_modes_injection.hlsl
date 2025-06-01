#ifndef DIRECT_MODES_INJECTION
#define DIRECT_MODES_INJECTION

#include "../../core/structures/fermion_mode_data.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/fermion_field_state_ops.hlsl"
#include "../../core/formalisms/dirac_formalism.hlsl"

namespace FieldModesInjection
{
    /// This namespace implements mode injection in a simple and direct way
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace DirectModesInjection
    {
        // Inject a fermion mode at a specified position with a specified field index
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void inject_fermion_mode(float3 position, FermionModeData mode_data)
        {
            uint field_index = uint(mode_data[0] - 1);
            float amplitude = mode_data[1];
            float3 origin = float3(mode_data[2], mode_data[3], mode_data[4]);
            float3 wave_vector = float3(mode_data[5], mode_data[6], mode_data[7]);
            float3 spin_vector = float3(mode_data[8], mode_data[9], mode_data[10]);
            float3 inverse_gaussian_width = float3(mode_data[11], mode_data[12], mode_data[13]);

            uint buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
            FermionFieldProperties field_properties = fermion_field_properties[field_index];
            float field_mass = field_properties.field_mass;

            FermionFieldState new_state;

            DiracFormalism::construct_spin_state(spin_vector, wave_vector, field_mass, new_state);
            float3 delta_position = position - origin;
            float2 position_phase = amplitude * ComplexNumbersMath::cxp(float2(-dot(delta_position * delta_position, inverse_gaussian_width * inverse_gaussian_width), dot(wave_vector, position - origin)));
            FermionFieldStateMath::scl(new_state, position_phase, new_state);

            FermionFieldState current_state = crnt_fermions_lattice_buffer[buffer_index];
            FermionFieldStateMath::sum(current_state, new_state, new_state);
            crnt_fermions_lattice_buffer[buffer_index] = new_state;

            float2 time_phase = ComplexNumbersMath::cxp(float2(0, sqrt(dot(wave_vector, wave_vector) + field_mass * field_mass) * simulation_temporal_unit));
            FermionFieldStateMath::scl(new_state, time_phase, new_state);

            FermionFieldState previous_state = prev_fermions_lattice_buffer[buffer_index];
            FermionFieldStateMath::sum(previous_state, new_state, new_state);
            prev_fermions_lattice_buffer[buffer_index] = new_state;
        }

        // Inject all fermion modes in the buffer at a specified position
        // * Side Effects:
        // • Reads directly from the simulation's fermion modes buffer
        // • Writes directly to the simulation's lattice buffers
        void inject_fermion_modes(float3 position)
        {
            for (uint i = 0; i < FERMION_MODES_BUFFER_LENGTH; i++)
            {
                FermionModeData mode_data = fermion_modes_buffer[i];
                if (mode_data[0] < 1) return;
                inject_fermion_mode(position, mode_data);
            }
        }
    }
}

#endif
