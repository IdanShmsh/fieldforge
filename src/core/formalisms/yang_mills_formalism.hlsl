#ifndef YANG_MILLS_FORMALISM
#define YANG_MILLS_FORMALISM

#include "../structures/gauge_symmetries_vector_pack.hlsl"
#include "../analysis/gauge_field_differentials.hlsl" // should not depend directly on analysis (required to get the type "GaugeFieldsJacobian")
#include "gauge_structure_constants.hlsl"

typedef float4x4 GaugeFieldStrength[12]; // indices: [gauge-symmetry][spacetime-axis][spacetime-axis]

/// This namespace implements functions used to perform calculations involved in the Yang-Mills formalism.
namespace YangMillsFormalism
{
    // Takes the Yang-Mills gauge commutator via the data in two gauge vector packs
    // g f⁽ᵃᵇᶜ⁾ Aᵇμ Aᶜν for given: a, μ, ν
    // (g = simulation_non_abelian_self_interaction)
    float gauge_commutator(GaugeSymmetriesVectorPack gauge_vector_pack1, GaugeSymmetriesVectorPack gauge_vector_pack2, uint a, uint mu, uint nu)
    {
        if (simulation_non_abelian_self_interaction == 0) return 0;
        float3 structure_constants[2] = gauge_structure_constants[a];
        if (structure_constants[0][0] == 0) return 0; // prevent any computation if the structure constants are all 0
        return simulation_non_abelian_self_interaction *
            (gauge_vector_pack1[(uint)structure_constants[0][1]][mu] * gauge_vector_pack2[(uint)structure_constants[0][2]][nu] * structure_constants[0][0] -
            gauge_vector_pack1[(uint)structure_constants[0][2]][mu] * gauge_vector_pack2[(uint)structure_constants[0][1]][nu] * structure_constants[0][0] +
            gauge_vector_pack1[(uint)structure_constants[1][1]][mu] * gauge_vector_pack2[(uint)structure_constants[1][2]][nu] * structure_constants[0][0] -
            gauge_vector_pack1[(uint)structure_constants[1][2]][mu] * gauge_vector_pack2[(uint)structure_constants[1][1]][nu] * structure_constants[0][0]);
    }

    // Computes the field strength tensor for the specified set of gauge potentials with their local configuration provided via their jacobian
    // Fμνᵃ = ∂μ Avᵃ - ∂ν Aμᵃ - g f⁽ᵃᵇᶜ⁾ Aᵇμ Aᶜν
    // (g = simulation_non_abelian_self_interaction)
    void field_strength_tensor(GaugeSymmetriesVectorPack gauge_potentials_pack, GaugeFieldsJacobian gauge_potentials_jacobian, out GaugeFieldStrength field_strength_tensor) {
        [unroll] for (uint a = 0; a < 12; a++) field_strength_tensor[a] = gauge_potentials_jacobian[a] - transpose(gauge_potentials_jacobian[a]);
        if (simulation_non_abelian_self_interaction == 0) return;
        [unroll] for (uint a = 0; a < 12; a++) [unroll] for (uint m = 0; m < 4; m++) [unroll] for (uint n = 0; n < 4; n++) field_strength_tensor[a][m][n] -= gauge_commutator(gauge_potentials_pack, gauge_potentials_pack, a, m, n);
    }

    // Extracts the n-th column from a provided field strength tensor
    void field_strength_column(GaugeFieldStrength field_strength_tensor, uint n, out GaugeSymmetriesVectorPack column) {
        [unroll] for (uint a = 0; a < 12; a++) column[a] = transpose(field_strength_tensor[a])[n];
    }

    // Extracts the m-th row from a provided field strength tensor
    void field_strength_row(GaugeFieldStrength field_strength_tensor, uint m, out GaugeSymmetriesVectorPack row) {
        [unroll] for (uint a = 0; a < 12; a++) row[a] = field_strength_tensor[a][m];
    }

    // Extracts the electric field strengths from a provided field strength tensor
    void field_strength_electric(GaugeFieldStrength field_strength_tensor, out GaugeSymmetriesVectorPack electric_field_strength) {
        [unroll] for (uint a = 0; a < 12; a++) electric_field_strength[a] = float4(0, field_strength_tensor[a][0][1], field_strength_tensor[a][0][2], field_strength_tensor[a][0][3]);
    }

    // Extracts the magnetic field strengths from a provided field strength tensor
    void field_strength_magnetic(GaugeFieldStrength field_strength_tensor, out GaugeSymmetriesVectorPack magnetic_field_strength) {
        [unroll] for (uint a = 0; a < 12; a++) magnetic_field_strength[a] = float4(0, field_strength_tensor[a][3][2], field_strength_tensor[a][1][3], field_strength_tensor[a][2][1]);
    }
}

#endif
