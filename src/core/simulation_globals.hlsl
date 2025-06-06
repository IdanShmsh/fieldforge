
/// This file outlines and declares the global variables and structures used in the simulation.
/// All variables accept an external value assignment loaded by the CPU.

#ifndef SIMULATION_DATA
#define SIMULATION_DATA

#include "structures/fermion_field_state.hlsl"
#include "structures/gauge_symmetries_vector_pack.hlsl"
#include "structures/fermion_field_properties.hlsl"
#include "structures/simulation_poke_data.hlsl"
#include "structures/simulation_barrier_data.hlsl"
#include "structures/fermion_mode_data.hlsl"

#ifndef SPATIAL_DIMENSIONALITY
#define SPATIAL_DIMENSIONALITY 3
#endif

#ifndef FERMION_FIELDS_COUNT
#define FERMION_FIELDS_COUNT 8
#endif

#ifndef POKES_BUFFER_LENGTH
#define POKES_BUFFER_LENGTH 16
#endif

#ifndef BARRIERS_BUFFER_LENGTH
#define BARRIERS_BUFFER_LENGTH 16
#endif

#ifndef FERMION_MODES_BUFFER_LENGTH
#define FERMION_MODES_BUFFER_LENGTH 1024
#endif

// Storing the simulation runtime properties
int simulation_width;
int simulation_height;
int simulation_depth;
float simulation_spatial_unit;
float simulation_temporal_unit;
float simulation_non_abelian_self_interaction;
float simulation_fermion_density_limit;
float simulation_gauge_norm_limit;
int simulation_field_mask;
float simulation_brightness = 1;

// Storing the properties of the spinor fields
RWStructuredBuffer<FermionFieldProperties> fermion_field_properties;

// Each lattice would be stored across 3 temporal instances - previous, current, next

// Storing the state lattice of the spinor fields
FermionLatticeBuffer prev_fermions_lattice_buffer;
FermionLatticeBuffer crnt_fermions_lattice_buffer;
FermionLatticeBuffer next_fermions_lattice_buffer;
FermionLatticeBuffer rend_fermions_lattice_buffer; // A lattice prepared for rendering
// Storing the state lattice of the gauge fields (3 buffers - previous, current, next)
GaugeLatticeBuffer prev_gauge_potentials_lattice_buffer;
GaugeLatticeBuffer crnt_gauge_potentials_lattice_buffer;
GaugeLatticeBuffer next_gauge_potentials_lattice_buffer;
GaugeLatticeBuffer rend_gauge_potentials_lattice_buffer; // A lattice prepared for rendering
// Storing the state lattice of the gauge fields' strength
GaugeLatticeBuffer prev_electric_strengths_lattice_buffer;
GaugeLatticeBuffer crnt_electric_strengths_lattice_buffer;
GaugeLatticeBuffer next_electric_strengths_lattice_buffer;
GaugeLatticeBuffer rend_electric_strengths_lattice_buffer; // A lattice prepared for rendering
GaugeLatticeBuffer prev_magnetic_strengths_lattice_buffer;
GaugeLatticeBuffer crnt_magnetic_strengths_lattice_buffer;
GaugeLatticeBuffer next_magnetic_strengths_lattice_buffer;
GaugeLatticeBuffer rend_magnetic_strengths_lattice_buffer;

// Storing the dynamic poke input data for the simulation
RWStructuredBuffer<SimulationPokeData> simulation_pokes_buffer;
// Storing the dynamic barrier data for the simulation
RWStructuredBuffer<SimulationBarrierInformation> simulation_barriers_buffer;
// Storing the dynamic fermion modes data for the simulation
RWStructuredBuffer<FermionModeData> fermion_modes_buffer;

// Some intrinsic values the simulation needs an allocated global memory for - at least 64 units
RWStructuredBuffer<int> global_intrinsics : register(u0);

#endif
