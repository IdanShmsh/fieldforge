#ifndef FERMION_FIELD_PROPERTIES
#define FERMION_FIELD_PROPERTIES

/// This data structure stores the properties of a single spinor field in the simulation
struct FermionFieldProperties
{
    half4 color; // RGB color value
    half field_mass; // half - the mass of the field
    half u1_interaction_coupling; // u1 coupling constant
    half su2_interaction_coupling; // su2 coupling constant
    half su3_interaction_coupling; // su3 coupling constant
};

#endif
