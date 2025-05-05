#ifndef WILSON_FORMALISM
#define WILSON_FORMALISM

#include "fermion_state_symmetry_transformations.hlsl"
#include "../math/gauge_symmetries_vector_pack_math.hlsl"
#include "../structures/fermion_field_state.hlsl"

/// This namespace implements functions used to perform calculations involved in the Wilson Formalism for
/// lattice gauge theory.
namespace WilsonFormalism
{
    // Parallel transport a fermion state a single lattice step in the direction of a specified axis across
    // the U1 gauge field with the given potential and a coupling constant.
    void parallel_transport_fermion_u1(FermionFieldState fermion_state, GaugeSymmetriesVectorPack gauge_potentials, uint axis, float u1_gauge_coupling_constant, out FermionFieldState transported_fermion_state)
    {
        float theta = u1_gauge_coupling_constant * gauge_potentials[0][axis];
        FermionFieldStateMath::phase_rot(fermion_state, theta, transported_fermion_state);
    }

    // Parallel transport a fermion state a single lattice step in the direction of a specified axis across
    // the SU(2) gauge field with the given potential and a coupling constant, as a doublet constructed with
    // a specified weak partner state and it's (the target fermion's) weak doublet index.
    void parallel_transport_fermion_su2(FermionFieldState fermion_state, FermionFieldState weak_partner_state, GaugeSymmetriesVectorPack gauge_potentials, uint axis, float su2_gauge_coupling_constant, bool weak_doublet_index, out FermionFieldState transported_fermion_state)
    {
        FermionFieldState doublet_fermion_state1, doublet_fermion_state2;
        if (weak_doublet_index)
        {
            FermionFieldStateOps::dup(fermion_state, doublet_fermion_state1);
            FermionFieldStateOps::dup(weak_partner_state, doublet_fermion_state2);
        }
        else
        {
            FermionFieldStateOps::dup(weak_partner_state, doublet_fermion_state1);
            FermionFieldStateOps::dup(fermion_state, doublet_fermion_state2);
        }
        FermionStateSymmetryTransformations::sigma1(doublet_fermion_state1, doublet_fermion_state2, su2_gauge_coupling_constant * gauge_potentials[1][axis], doublet_fermion_state1, doublet_fermion_state2);
        FermionStateSymmetryTransformations::sigma2(doublet_fermion_state1, doublet_fermion_state2, su2_gauge_coupling_constant * gauge_potentials[2][axis], doublet_fermion_state1, doublet_fermion_state2);
        FermionStateSymmetryTransformations::sigma3(doublet_fermion_state1, doublet_fermion_state2, su2_gauge_coupling_constant * gauge_potentials[3][axis], doublet_fermion_state1, doublet_fermion_state2);
        if (weak_doublet_index) transported_fermion_state = doublet_fermion_state1;
        else transported_fermion_state = doublet_fermion_state2;
    }

    // Parallel transport a fermion state a single lattice step in the direction of a specified axis across
    // the SU(3) gauge field with the given potential and a coupling constant.
    void parallel_transport_fermion_su3(FermionFieldState fermion_state, GaugeSymmetriesVectorPack gauge_potentials, uint axis, float su3_gauge_coupling_constant, out FermionFieldState transported_fermion_state)
    {
        transported_fermion_state = fermion_state;
        FermionStateSymmetryTransformations::lambda1(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[4][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda2(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[5][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda3(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[6][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda4(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[7][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda5(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[8][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda6(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[9][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda7(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[10][axis], transported_fermion_state);
        FermionStateSymmetryTransformations::lambda8(transported_fermion_state, su3_gauge_coupling_constant * gauge_potentials[11][axis], transported_fermion_state);
    }

    // Parallel transport a fermion state a single lattice step in the direction of a specified axis across
    // the gauge fields with the given potentials and coupling constants.
    void parallel_transport_fermion(FermionFieldState fermion_state, FermionFieldState weak_partner_state, GaugeSymmetriesVectorPack gauge_potentials, uint axis, float3 gauge_coupling_constants, bool weak_doublet_index, out FermionFieldState transported_fermion_state)
    {
        transported_fermion_state = fermion_state;
        if (gauge_coupling_constants[0]) parallel_transport_fermion_u1(transported_fermion_state, gauge_potentials, axis, gauge_coupling_constants[0], transported_fermion_state);
        if (gauge_coupling_constants[1]) parallel_transport_fermion_su2(transported_fermion_state, weak_partner_state, gauge_potentials, axis, gauge_coupling_constants[1], weak_doublet_index, transported_fermion_state);
        if (gauge_coupling_constants[2]) parallel_transport_fermion_su3(transported_fermion_state, gauge_potentials, axis, gauge_coupling_constants[2], transported_fermion_state);
    }

    // Backward parallel transport a fermion state a single lattice step in the direction of a specified axis across
    // the gauge fields with the given potentials and coupling constants.
    void backward_parallel_transport_fermion(FermionFieldState fermion_state, FermionFieldState weak_partner_state, GaugeSymmetriesVectorPack gauge_potentials, uint axis, float3 gaugeCouplingConstants, bool weakDoubletIndex, out FermionFieldState transportedSpinor)
    {
        transportedSpinor = fermion_state;
        GaugeSymmetriesVectorPackMath::scl(gauge_potentials, -1, gauge_potentials);
        parallel_transport_fermion(transportedSpinor, weak_partner_state, gauge_potentials, axis, gaugeCouplingConstants, weakDoubletIndex, transportedSpinor);
    }
}

#endif
