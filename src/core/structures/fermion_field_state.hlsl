#ifndef FERMION_FIELD_STATE
#define FERMION_FIELD_STATE

/// This data structure stores the data of a single fermion field at a single point in the lattice.
typedef float2 FermionFieldState[12];  // [[Im(\psi_{i,j}, \psi_{i,j}) * (i \in {0, 1, 2, 3}, j \in {0, 1, 2} = 4 * 3 = 12 components)]]

/// An alias for specifying the type associated with a buffer that stores fermion field states (a fermion lattice).
typedef RWStructuredBuffer<FermionFieldState> FermionLatticeBuffer;

#endif
