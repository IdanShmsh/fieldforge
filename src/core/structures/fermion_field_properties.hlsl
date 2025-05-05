#ifndef FERMION_FIELD_PROPERTIES
#define FERMION_FIELD_PROPERTIES

/// This data structure stores the properties of a single spinor field in the simulation
struct FermionFieldProperties
{
    float4 color; // RGB color value
    float field_mass; // float - the mass of the field
    float u1_interaction_coupling; // u1 coupling constant
    float su2_interaction_coupling; // su2 coupling constant
    float su3_interaction_coupling; // su3 coupling constant
};

#endif
