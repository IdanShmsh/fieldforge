#ifndef FERMION_MODE_DATA
#define FERMION_MODE_DATA

/// This data structure stores the properties of a single fermion mode injection item
typedef float FermionModeData[11]; // field_index + 1 (0 indicates an inactive injection), amplitude, origin_x, origin_y, origin_z ,wave_vector_x, wave_vector_y, wave_vector_z, spin_state_x, spin_state_y, spin_state_z

#endif
