#ifndef GAUGE_FIELDS_STATE_STRUCTURE_OPS
#define GAUGE_FIELDS_STATE_STRUCTURE_OPS

#include "../structures/gauge_symmetries_vector_pack.hlsl"

/// This namespace implements functions used to perform basic operations on the gauge-symmetries-vector-pack data structure.
namespace GaugeSymmetriesVectorPackOps
{
    // Empty (zero) a gauge field state
    void empty(out GaugeSymmetriesVectorPack vector_pack)
    {
        vector_pack[0] = float4(0, 0, 0, 0);
        vector_pack[1] = float4(0, 0, 0, 0);
        vector_pack[2] = float4(0, 0, 0, 0);
        vector_pack[3] = float4(0, 0, 0, 0);
        vector_pack[4] = float4(0, 0, 0, 0);
        vector_pack[5] = float4(0, 0, 0, 0);
        vector_pack[6] = float4(0, 0, 0, 0);
        vector_pack[7] = float4(0, 0, 0, 0);
        vector_pack[8] = float4(0, 0, 0, 0);
        vector_pack[9] = float4(0, 0, 0, 0);
        vector_pack[10] = float4(0, 0, 0, 0);
        vector_pack[11] = float4(0, 0, 0, 0);
    }

    // Get the gauge fields state index of the U(1) potential
    uint get_u1_symmetry_index()
    {
        return 0;
    }

    // Get the gauge fields state index of the SU(2) potential
    uint get_su2_field_index(uint su2_symmetry_index)
    {
        return 1 + su2_symmetry_index;
    }

    // Get the gauge fields state index of the SU(3) potential
    uint get_su3_field_index(uint su3_symmetry_index)
    {
        return 4 + su3_symmetry_index;
    }

    // Get the gauge potential associated with the U(1) symmetry from a gauge fields state
    float4 get_u1_gauge_potential(GaugeSymmetriesVectorPack gauge_fields_state)
    {
        return gauge_fields_state[get_u1_symmetry_index()];
    }

    // Get the gauge potential associated with a SU(2) symmetry from a gauge fields state
    float4 get_su2_gauge_potential(GaugeSymmetriesVectorPack gauge_fields_state, float su2_symmetry_index)
    {
        return gauge_fields_state[get_su2_field_index(su2_symmetry_index)];
    }

    // Get the gauge potential associated with a SU(3) symmetry from a gauge fields state
    float4 get_su3_gauge_potential(GaugeSymmetriesVectorPack gauge_fields_state, float su3_symmetry_index)
    {
        return gauge_fields_state[get_su3_field_index(su3_symmetry_index)];
    }

    // Set the gauge potential associated with the U(1) symmetry in a gauge fields state
    void set_u1_potential(GaugeSymmetriesVectorPack gauge_fields_state, float4 gauge_potential, out GaugeSymmetriesVectorPack modified_gauge_fields_state)
    {
        modified_gauge_fields_state = gauge_fields_state;
        modified_gauge_fields_state[get_u1_symmetry_index()] = gauge_potential;
    }

    // Set the gauge potential associated with a SU(2) symmetry in a gauge fields state
    void set_su2_potential(GaugeSymmetriesVectorPack gauge_fields_state, float4 gauge_potential, float su2_symmetry_index, out GaugeSymmetriesVectorPack modified_gauge_fields_state)
    {
        modified_gauge_fields_state = gauge_fields_state;
        modified_gauge_fields_state[get_su2_field_index(su2_symmetry_index)] = gauge_potential;
    }

    // Set the gauge potential associated with a SU(3) symmetry in a gauge fields state
    void set_su3_potential(GaugeSymmetriesVectorPack gauge_fields_state, float4 gauge_potential, float su3_symmetry_index, out GaugeSymmetriesVectorPack modified_gauge_fields_state)
    {
        modified_gauge_fields_state = gauge_fields_state;
        modified_gauge_fields_state[get_su3_field_index(su3_symmetry_index)] = gauge_potential[0];
    }

    // Check if a gauge field state is zero
    bool is_zero(GaugeSymmetriesVectorPack gauge_fields_state)
    {
        for (uint i = 0; i < 12; i++) if (any(gauge_fields_state[i])) return false;
        return true;
    }

    // Check if a gauge field state is below a certain provided tolerance threshold
    bool is_zero(GaugeSymmetriesVectorPack gauge_fields_state, float numerical_tolerance)
    {
        for (uint i = 0; i < 12; i++) if (any(abs(gauge_fields_state[i]) > numerical_tolerance)) return false;
        return true;
    }

    // Apply a bit-mask to a gauge symmetries vector pack (where bit-0 should be associated with the a=0 gauge symmetry)
    void apply_mask(int mask, GaugeSymmetriesVectorPack guage_fields_state, out GaugeSymmetriesVectorPack masked_gauge_symmetries_vector_pack)
    {
        for (int a = 0; a < 12; a++) masked_gauge_symmetries_vector_pack[a] = ((mask & 1 << a) != 0) * guage_fields_state[a];
    }
}

#endif
