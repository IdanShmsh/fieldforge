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
        void inject_fermion_mode(half3 position, FermionModeData mode_data)
        {
            uint field_index = uint(mode_data[0] - 1);
            half amplitude = mode_data[1];
            half3 origin = half3(mode_data[2], mode_data[3], mode_data[4]);
            half3 wave_vector = half3(mode_data[5], mode_data[6], mode_data[7]);
            half3 spin_vector = half3(mode_data[8], mode_data[9], mode_data[10]);
            half3 inverse_gaussian_width = half3(mode_data[11], mode_data[12], mode_data[13]);

            uint buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, field_index);
            FermionFieldProperties field_properties = fermion_field_properties[field_index];
            half field_mass = field_properties.field_mass;

            half3 delta_position = position - origin;
            half3 effective_momentum = sin(wave_vector) / simulation_spatial_unit;
            half wilson_mass_shift = (simulation_wilson_r / simulation_spatial_unit) * ((1 - cos(wave_vector.x)) + (1 - cos(wave_vector.y)) + (1 - cos(wave_vector.z)));
            half effective_mass = field_mass + wilson_mass_shift;
            half continuum_energy = sqrt(dot(effective_momentum, effective_momentum) + effective_mass * effective_mass);
            half effective_energy = asin(clamp(continuum_energy * simulation_temporal_unit, -1.0h, 1.0h)) / simulation_temporal_unit;

            FermionFieldState injected_state;
            DiracFormalism::construct_spin_state(spin_vector, effective_momentum, effective_mass, injected_state);
            half2 position_phase = amplitude * ComplexNumbersMath::cxp(half2(-dot(delta_position * delta_position, inverse_gaussian_width * inverse_gaussian_width), dot(wave_vector, delta_position)));
            FermionFieldStateMath::scl(injected_state, position_phase, injected_state);

            FermionFieldState injected_previous_state;
            half2 temporal_phase = ComplexNumbersMath::cxp(half2(0, effective_energy * simulation_temporal_unit));
            FermionFieldStateMath::scl(injected_state, temporal_phase, injected_previous_state);

            FermionFieldState current_state = crnt_fermions_lattice_buffer[buffer_index];
            FermionFieldState previous_state = prev_fermions_lattice_buffer[buffer_index];

            FermionFieldStateMath::sum(previous_state, injected_previous_state, previous_state);
            FermionFieldStateMath::sum(current_state, injected_state, current_state);

            prev_fermions_lattice_buffer[buffer_index] = previous_state;
            crnt_fermions_lattice_buffer[buffer_index] = current_state;
        }

        // Inject all fermion modes in the buffer at a specified position
        // * Side Effects:
        // • Reads directly from the simulation's fermion modes buffer
        // • Writes directly to the simulation's lattice buffers
        void inject_fermion_modes(half3 position)
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
