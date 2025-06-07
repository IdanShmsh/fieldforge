#ifndef FIELD_INTERPOLATIONS
#define FIELD_INTERPOLATIONS

#include "../formalisms/dirac_formalism.hlsl"
#include "../formalisms/yang_mills_formalism.hlsl"

namespace FieldInterpolations
{
    void get_fermion_state_in_position(float3 position, uint fermion_field_index, FermionLatticeBuffer field_buffer, out FermionFieldState fermion_state)
    {
        float3 fraction = position - floor(position);
        FermionFieldState f000, f001, f010, f011, f100, f101, f110, f111;
        float3 index_floor = floor(position);
        float3 index_ceil = ceil(position);
        uint buffer_index = 0;
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z), fermion_field_index);
        f000 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z), fermion_field_index);
        f100 = field_buffer[buffer_index];
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z), fermion_field_index);
        f010 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z), fermion_field_index);
        f110 = field_buffer[buffer_index];
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z), fermion_field_index);
        f001 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z), fermion_field_index);
        f011 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z), fermion_field_index);
        f101 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z), fermion_field_index);
        f111 = field_buffer[buffer_index];
        FermionFieldState f00, f01, f10, f11;
        #if SPATIAL_DIMENSIONALITY > 2
        FermionFieldStateMath::lerp_states(f000, f001, fraction.z, f00);
        FermionFieldStateMath::lerp_states(f010, f011, fraction.z, f01);
        FermionFieldStateMath::lerp_states(f100, f101, fraction.z, f10);
        FermionFieldStateMath::lerp_states(f110, f111, fraction.z, f11);
        #else
        f00 = f000;
        f01 = f010;
        f10 = f100;
        f11 = f110;
        #endif
        FermionFieldState f0, f1;
        #if SPATIAL_DIMENSIONALITY > 1
        FermionFieldStateMath::lerp_states(f00, f01, fraction.y, f0);
        FermionFieldStateMath::lerp_states(f10, f11, fraction.y, f1);
        #else
        f0 = f00;
        f1 = f10;
        #endif
        FermionFieldStateMath::lerp_states(f0, f1, fraction.x, fermion_state);
    }

    void get_gauge_state_in_position(float3 position, GaugeLatticeBuffer field_buffer, out GaugeSymmetriesVectorPack gauge_state)
    {
        float3 fraction = position - floor(position);
        GaugeSymmetriesVectorPack f000, f001, f010, f011, f100, f101, f110, f111;
        float3 index_floor = floor(position);
        float3 index_ceil = ceil(position);
        uint buffer_index = 0;
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_floor.z));
        f000 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_floor.z));
        f100 = field_buffer[buffer_index];
        #if SPATIAL_DIMENSIONALITY < 2
        return;
        #endif
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_floor.z));
        f010 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_floor.z));
        f110 = field_buffer[buffer_index];
        #if SPATIAL_DIMENSIONALITY < 3
        return;
        #endif
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_floor.y, index_ceil.z));
        f001 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_floor.x, index_ceil.y, index_ceil.z));
        f011 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_floor.y, index_ceil.z));
        f101 = field_buffer[buffer_index];
        buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(float3(index_ceil.x, index_ceil.y, index_ceil.z));
        f111 = field_buffer[buffer_index];
        GaugeSymmetriesVectorPack f00, f01, f10, f11;
        #if SPATIAL_DIMENSIONALITY > 2
        GaugeSymmetriesVectorPackMath::lerp_states(f000, f001, fraction.z, f00);
        GaugeSymmetriesVectorPackMath::lerp_states(f010, f011, fraction.z, f01);
        GaugeSymmetriesVectorPackMath::lerp_states(f100, f101, fraction.z, f10);
        GaugeSymmetriesVectorPackMath::lerp_states(f110, f111, fraction.z, f11);
        #else
        f00 = f000;
        f01 = f010;
        f10 = f100;
        f11 = f110;
        #endif
        GaugeSymmetriesVectorPack f0, f1;
        #if SPATIAL_DIMENSIONALITY > 1
        GaugeSymmetriesVectorPackMath::lerp_states(f00, f01, fraction.y, f0);
        GaugeSymmetriesVectorPackMath::lerp_states(f10, f11, fraction.y, f1);
        #else
        f0 = f00;
        f1 = f10;
        #endif
        GaugeSymmetriesVectorPackMath::lerp_states(f0, f1, fraction.x, gauge_state);
    }
}

#endif
