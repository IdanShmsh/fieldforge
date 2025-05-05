#ifndef SIMULATION_TO_SCREEN_SPACE
#define SIMULATION_TO_SCREEN_SPACE

#include "../core/ops/simulation_data_ops.hlsl"
#include "../core/formalisms/dirac_formalism.hlsl"

/// This namespace implements functions used to project data saved in simulation space to screen space.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace SimulationToScreenSpace
{
    // This function performs trilinear interpolation in 3D space.
    void _interpolate_3d(float3 position, float values[8], out float result)
    {
        float3 fraction = position - floor(position);
        float v000 = values[0];
        float v001 = values[1];
        float v010 = values[2];
        float v011 = values[3];
        float v100 = values[4];
        float v101 = values[5];
        float v110 = values[6];
        float v111 = values[7];
        #if SPATIAL_DIMENSIONALITY > 2
        float v00 = lerp(v000, v001, fraction.z);
        float v01 = lerp(v010, v011, fraction.z);
        float v10 = lerp(v100, v101, fraction.z);
        float v11 = lerp(v110, v111, fraction.z);
        #else
        float v00 = v000;
        float v01 = v010;
        float v10 = v100;
        float v11 = v110;
        #endif
        #if SPATIAL_DIMENSIONALITY > 1
        float v0 = lerp(v00, v01, fraction.y);
        float v1 = lerp(v10, v11, fraction.y);
        #else
        float v0 = v00;
        float v1 = v10;
        #endif
        result = lerp(v0, v1, fraction.x);
    }

    // This function performs trilinear interpolation in 3D space.
    void _interpolate_3d(float3 position, float3 values[8], out float3 result)
    {
        float3 fraction = position - floor(position);
        float3 v000 = values[0];
        float3 v001 = values[1];
        float3 v010 = values[2];
        float3 v011 = values[3];
        float3 v100 = values[4];
        float3 v101 = values[5];
        float3 v110 = values[6];
        float3 v111 = values[7];
        #if SPATIAL_DIMENSIONALITY > 2
        float3 v00 = lerp(v000, v001, fraction.z);
        float3 v01 = lerp(v010, v011, fraction.z);
        float3 v10 = lerp(v100, v101, fraction.z);
        float3 v11 = lerp(v110, v111, fraction.z);
        #else
        float3 v00 = v000;
        float3 v01 = v010;
        float3 v10 = v100;
        float3 v11 = v110;
        #endif
        #if SPATIAL_DIMENSIONALITY > 1
        float3 v0 = lerp(v00, v01, fraction.y);
        float3 v1 = lerp(v10, v11, fraction.y);
        #else
        float3 v0 = v00;
        float3 v1 = v10;
        #endif
        result = lerp(v0, v1, fraction.x);
    }

    // This function performs trilinear interpolation in 3D space.
    void _interpolate_3d(float3 position, float4 values[8], out float4 result)
    {
        float3 fraction = position - floor(position);
        float4 v000 = values[0];
        float4 v001 = values[1];
        float4 v010 = values[2];
        float4 v011 = values[3];
        float4 v100 = values[4];
        float4 v101 = values[5];
        float4 v110 = values[6];
        float4 v111 = values[7];
        #if SPATIAL_DIMENSIONALITY > 2
        float4 v00 = lerp(v000, v001, fraction.z);
        float4 v01 = lerp(v010, v011, fraction.z);
        float4 v10 = lerp(v100, v101, fraction.z);
        float4 v11 = lerp(v110, v111, fraction.z);
        #else
        float4 v00 = v000;
        float4 v01 = v010;
        float4 v10 = v100;
        float4 v11 = v110;
        #endif
        #if SPATIAL_DIMENSIONALITY > 1
        float4 v0 = lerp(v00, v01, fraction.y);
        float4 v1 = lerp(v10, v11, fraction.y);
        #else
        float4 v0 = v00;
        float4 v1 = v10;
        #endif
        result = lerp(v0, v1, fraction.x);
    }

    // This function gathers the norms of 8 fermion fields at lattice positions representing the 8 corners of a cube
    // that surrounds the specified position.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void _gather_8_fermion_norms(float3 position, uint fermoin_field_index, FermionLatticeBuffer fermions_lattice_buffer, out float values[8])
    {
        float3 index_floor = floor(position);
        float3 index_ceil = ceil(position);
        uint index;
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z), fermoin_field_index);
        values[0] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z), fermoin_field_index);
        values[4] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z), fermoin_field_index);
        values[2] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z), fermoin_field_index);
        values[6] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z), fermoin_field_index);
        values[1] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z), fermoin_field_index);
        values[3] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z), fermoin_field_index);
        values[5] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z), fermoin_field_index);
        values[7] = FermionFieldStateMath::norm(fermions_lattice_buffer[index]);
    }

    // This function gathers the Dirac norms of 8 fermion fields at lattice positions representing the 8 corners of a cube
    // that surrounds the specified position.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void _gather_8_fermion_dirac_norms(float3 position, uint spinorFieldIndex, FermionLatticeBuffer fieldBuffer, out float values[8])
    {
        float3 index_floor = floor(position);
        float3 index_ceil = ceil(position);
        uint index;
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z), spinorFieldIndex);
        values[0] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z), spinorFieldIndex);
        values[4] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z), spinorFieldIndex);
        values[2] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z), spinorFieldIndex);
        values[6] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z), spinorFieldIndex);
        values[1] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z), spinorFieldIndex);
        values[3] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z), spinorFieldIndex);
        values[5] = DiracFormalism::dirac_norm(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z), spinorFieldIndex);
        values[7] = DiracFormalism::dirac_norm(fieldBuffer[index]);
    }

    // This function gathers the spin states of 8 fermion fields at lattice positions representing the 8 corners of a cube
    // that surrounds the specified position.
    void _gather_8_fermion_spin_states(float3 position, uint spinorFieldIndex, FermionLatticeBuffer fieldBuffer, out float3 values[8])
    {
        float3 index_floor = floor(position);
        float3 index_ceil = ceil(position);
        uint index;
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z), spinorFieldIndex);
        values[0] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z), spinorFieldIndex);
        values[4] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z), spinorFieldIndex);
        values[2] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z), spinorFieldIndex);
        values[6] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z), spinorFieldIndex);
        values[1] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z), spinorFieldIndex);
        values[3] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z), spinorFieldIndex);
        values[5] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
        index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z), spinorFieldIndex);
        values[7] = DiracFormalism::obtain_spin_state(fieldBuffer[index]);
    }

    // This function gathers the gauge potential norms of 8 gauge fields at lattice positions representing the 8 corners of a cube
    // that surrounds the specified position.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void _gather_8_gauge_potential_norms(float3 position, uint symmetry_index, GaugeLatticeBuffer field_buffer, out float4 values[8])
    {
        int3 index_floor = floor(position);
        int3 index_ceil = ceil(position);
        uint index;
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z));
        values[0] = field_buffer[index][symmetry_index];
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z));
        values[4] = field_buffer[index][symmetry_index];
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z));
        values[2] = field_buffer[index][symmetry_index];
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z));
        values[6] = field_buffer[index][symmetry_index];
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z));
        values[1] = field_buffer[index][symmetry_index];
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z));
        values[3] = field_buffer[index][symmetry_index];
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z));
        values[5] = field_buffer[index][symmetry_index];
        index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z));
        values[7] = field_buffer[index][symmetry_index];
    }

    // This function computes the norm of the fermion field at a given non-integer position in the simulation space.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void get_fermion_field_norm(float3 position, uint spinor_field_index, FermionLatticeBuffer field_buffer, out float state_norm)
    {
        float values[8];
        float3 clamped_position = SimulationDataOps::clamp_position(position);
        _gather_8_fermion_norms(clamped_position, spinor_field_index, field_buffer, values);
        _interpolate_3d(position, values, state_norm);
    }

    // This function computes the Dirac norm of the fermion field at a given non-integer position in the simulation space.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void get_fermion_field_dirac_norm(float3 position, uint spinor_field_index, FermionLatticeBuffer field_buffer, out float state_norm)
    {
        float values[8];
        float3 clamped_position = SimulationDataOps::clamp_position(position);
        _gather_8_fermion_dirac_norms(clamped_position, spinor_field_index, field_buffer, values);
        _interpolate_3d(position, values, state_norm);
    }

    // This function computes the angular momentum of the fermion field at a given non-integer position in the simulation space.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void get_fermion_field_angular_momentum(float3 position, uint spinor_field_index, FermionLatticeBuffer field_buffer, out float3 state_angular_momentum)
    {
        float3 values[8];
        float3 clamped_position = SimulationDataOps::clamp_position(position);
        _gather_8_fermion_spin_states(clamped_position, spinor_field_index, field_buffer, values);
        _interpolate_3d(position, values, state_angular_momentum);
    }

    // This function computes the gauge potential at a given non-integer position in the simulation space.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers
    void get_gauge_field_component(float3 position, uint component_index, GaugeLatticeBuffer field_buffer, out float4 component_value)
    {
        float4 values[8];
        _gather_8_gauge_potential_norms(position, component_index, field_buffer, values);
        _interpolate_3d(position, values, component_value);
    }
}

#endif
