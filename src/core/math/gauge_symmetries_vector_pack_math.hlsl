#ifndef GAUGE_FIELDS_STATE_MATH
#define GAUGE_FIELDS_STATE_MATH

#include "../structures/gauge_symmetries_vector_pack.hlsl"
#include "../math/common_math.hlsl"

int GAUGE_FIELDS_MATH_LIST[12];

/// This namespace implements functions used to perform basic mathematical operations on gauge-symmetries-vector-packs.
namespace GaugeSymmetriesVectorPackMath
{
    // Sum all associated vectors in a pair of gauge-symmetries-vector-packs
    void sum(GaugeSymmetriesVectorPack vector_pack1, GaugeSymmetriesVectorPack vector_pack2, out GaugeSymmetriesVectorPack result)
    {
        result[0] = vector_pack1[0] + vector_pack2[0];
        result[1] = vector_pack1[1] + vector_pack2[1];
        result[2] = vector_pack1[2] + vector_pack2[2];
        result[3] = vector_pack1[3] + vector_pack2[3];
        result[4] = vector_pack1[4] + vector_pack2[4];
        result[5] = vector_pack1[5] + vector_pack2[5];
        result[6] = vector_pack1[6] + vector_pack2[6];
        result[7] = vector_pack1[7] + vector_pack2[7];
        result[8] = vector_pack1[8] + vector_pack2[8];
        result[9] = vector_pack1[9] + vector_pack2[9];
        result[10] = vector_pack1[10] + vector_pack2[10];
        result[11] = vector_pack1[11] + vector_pack2[11];
    }

    // Subtract all associated vectors in a pair of gauge-symmetries-vector-packs
    void sub(GaugeSymmetriesVectorPack vector_pack1, GaugeSymmetriesVectorPack vector_pack2, out GaugeSymmetriesVectorPack result)
    {
        result[0] = vector_pack1[0] - vector_pack2[0];
        result[1] = vector_pack1[1] - vector_pack2[1];
        result[2] = vector_pack1[2] - vector_pack2[2];
        result[3] = vector_pack1[3] - vector_pack2[3];
        result[4] = vector_pack1[4] - vector_pack2[4];
        result[5] = vector_pack1[5] - vector_pack2[5];
        result[6] = vector_pack1[6] - vector_pack2[6];
        result[7] = vector_pack1[7] - vector_pack2[7];
        result[8] = vector_pack1[8] - vector_pack2[8];
        result[9] = vector_pack1[9] - vector_pack2[9];
        result[10] = vector_pack1[10] - vector_pack2[10];
        result[11] = vector_pack1[11] - vector_pack2[11];
    }

    // Scale all vectors in a gauge-symmetries-vector-pack
    void scl(GaugeSymmetriesVectorPack vector_pack, float scalar, out GaugeSymmetriesVectorPack result)
    {
        result[0] = vector_pack[0] * scalar;
        result[1] = vector_pack[1] * scalar;
        result[2] = vector_pack[2] * scalar;
        result[3] = vector_pack[3] * scalar;
        result[4] = vector_pack[4] * scalar;
        result[5] = vector_pack[5] * scalar;
        result[6] = vector_pack[6] * scalar;
        result[7] = vector_pack[7] * scalar;
        result[8] = vector_pack[8] * scalar;
        result[9] = vector_pack[9] * scalar;
        result[10] = vector_pack[10] * scalar;
        result[11] = vector_pack[11] * scalar;
    }

    // Compute sum of overlaps between all associated vectors in a pair of gauge-symmetries-vector-packs
    float dot(GaugeSymmetriesVectorPack vector_pack1, GaugeSymmetriesVectorPack vector_pack2)
    {
        float result = 0;
        result += vector_pack1[0][0] * vector_pack2[0][0] + vector_pack1[0][1] * vector_pack2[0][1] + vector_pack1[0][2] * vector_pack2[0][2] + vector_pack1[0][3] * vector_pack2[0][3];
        result += vector_pack1[1][0] * vector_pack2[1][0] + vector_pack1[1][1] * vector_pack2[1][1] + vector_pack1[1][2] * vector_pack2[1][2] + vector_pack1[1][3] * vector_pack2[1][3];
        result += vector_pack1[2][0] * vector_pack2[2][0] + vector_pack1[2][1] * vector_pack2[2][1] + vector_pack1[2][2] * vector_pack2[2][2] + vector_pack1[2][3] * vector_pack2[2][3];
        result += vector_pack1[3][0] * vector_pack2[3][0] + vector_pack1[3][1] * vector_pack2[3][1] + vector_pack1[3][2] * vector_pack2[3][2] + vector_pack1[3][3] * vector_pack2[3][3];
        result += vector_pack1[4][0] * vector_pack2[4][0] + vector_pack1[4][1] * vector_pack2[4][1] + vector_pack1[4][2] * vector_pack2[4][2] + vector_pack1[4][3] * vector_pack2[4][3];
        result += vector_pack1[5][0] * vector_pack2[5][0] + vector_pack1[5][1] * vector_pack2[5][1] + vector_pack1[5][2] * vector_pack2[5][2] + vector_pack1[5][3] * vector_pack2[5][3];
        result += vector_pack1[6][0] * vector_pack2[6][0] + vector_pack1[6][1] * vector_pack2[6][1] + vector_pack1[6][2] * vector_pack2[6][2] + vector_pack1[6][3] * vector_pack2[6][3];
        result += vector_pack1[7][0] * vector_pack2[7][0] + vector_pack1[7][1] * vector_pack2[7][1] + vector_pack1[7][2] * vector_pack2[7][2] + vector_pack1[7][3] * vector_pack2[7][3];
        result += vector_pack1[8][0] * vector_pack2[8][0] + vector_pack1[8][1] * vector_pack2[8][1] + vector_pack1[8][2] * vector_pack2[8][2] + vector_pack1[8][3] * vector_pack2[8][3];
        result += vector_pack1[9][0] * vector_pack2[9][0] + vector_pack1[9][1] * vector_pack2[9][1] + vector_pack1[9][2] * vector_pack2[9][2] + vector_pack1[9][3] * vector_pack2[9][3];
        result += vector_pack1[10][0] * vector_pack2[10][0] + vector_pack1[10][1] * vector_pack2[10][1] + vector_pack1[10][2] * vector_pack2[10][2] + vector_pack1[10][3] * vector_pack2[10][3];
        result += vector_pack1[11][0] * vector_pack2[11][0] + vector_pack1[11][1] * vector_pack2[11][1] + vector_pack1[11][2] * vector_pack2[11][2] + vector_pack1[11][3] * vector_pack2[11][3];
        return result;
    }

    // Perform a linear combination between all associated vectors in a pair of gauge-symmetries-vector-packs
    void scl_sum(GaugeSymmetriesVectorPack vector_pack1, float scalar1, GaugeSymmetriesVectorPack vector_pack2, float scalar2, out GaugeSymmetriesVectorPack result)
    {
        result[0] = vector_pack1[0] * scalar1 + vector_pack2[0] * scalar2;
        result[1] = vector_pack1[1] * scalar1 + vector_pack2[1] * scalar2;
        result[2] = vector_pack1[2] * scalar1 + vector_pack2[2] * scalar2;
        result[3] = vector_pack1[3] * scalar1 + vector_pack2[3] * scalar2;
        result[4] = vector_pack1[4] * scalar1 + vector_pack2[4] * scalar2;
        result[5] = vector_pack1[5] * scalar1 + vector_pack2[5] * scalar2;
        result[6] = vector_pack1[6] * scalar1 + vector_pack2[6] * scalar2;
        result[7] = vector_pack1[7] * scalar1 + vector_pack2[7] * scalar2;
        result[8] = vector_pack1[8] * scalar1 + vector_pack2[8] * scalar2;
        result[9] = vector_pack1[9] * scalar1 + vector_pack2[9] * scalar2;
        result[10] = vector_pack1[10] * scalar1 + vector_pack2[10] * scalar2;
        result[11] = vector_pack1[11] * scalar1 + vector_pack2[11] * scalar2;
    }

    // Compute the norm squared of a gauge-symmetries-vector-pack (the sum of norm squares of all vectors in it)
    float norm_sqrd(GaugeSymmetriesVectorPack vector_pack)
    {
        return vector_pack[0] * vector_pack[0] + vector_pack[1] * vector_pack[1] + vector_pack[2] * vector_pack[2] + vector_pack[3] * vector_pack[3] +
               vector_pack[4] * vector_pack[4] + vector_pack[5] * vector_pack[5] + vector_pack[6] * vector_pack[6] + vector_pack[7] * vector_pack[7] +
               vector_pack[8] * vector_pack[8] + vector_pack[9] * vector_pack[9] + vector_pack[10] * vector_pack[10] + vector_pack[11] * vector_pack[11];
    }

    // Add a specified vector to all vectors in a gauge-symmetries-vector-pack (individually)
    void vec_sum(GaugeSymmetriesVectorPack vector_pack, float4 summand, out GaugeSymmetriesVectorPack result)
    {
        result[0] = vector_pack[0] + summand;
        result[1] = vector_pack[1] + summand;
        result[2] = vector_pack[2] + summand;
        result[3] = vector_pack[3] + summand;
        result[4] = vector_pack[4] + summand;
        result[5] = vector_pack[5] + summand;
        result[6] = vector_pack[6] + summand;
        result[7] = vector_pack[7] + summand;
        result[8] = vector_pack[8] + summand;
        result[9] = vector_pack[9] + summand;
        result[10] = vector_pack[10] + summand;
        result[11] = vector_pack[11] + summand;
    }

    // Interpolate between a pair of gauge-symmetries-vector-packs
    void lerp_states(GaugeSymmetriesVectorPack vector_pack1, GaugeSymmetriesVectorPack vector_pack2, float weight, out GaugeSymmetriesVectorPack result)
    {
        result[0] = lerp(vector_pack1[0], vector_pack2[0], weight);
        result[1] = lerp(vector_pack1[1], vector_pack2[1], weight);
        result[2] = lerp(vector_pack1[2], vector_pack2[2], weight);
        result[3] = lerp(vector_pack1[3], vector_pack2[3], weight);
        result[4] = lerp(vector_pack1[4], vector_pack2[4], weight);
        result[5] = lerp(vector_pack1[5], vector_pack2[5], weight);
        result[6] = lerp(vector_pack1[6], vector_pack2[6], weight);
        result[7] = lerp(vector_pack1[7], vector_pack2[7], weight);
        result[8] = lerp(vector_pack1[8], vector_pack2[8], weight);
        result[9] = lerp(vector_pack1[9], vector_pack2[9], weight);
        result[10] = lerp(vector_pack1[10], vector_pack2[10], weight);
        result[11] = lerp(vector_pack1[11], vector_pack2[11], weight);
    }

    // Limit the norms of all vectors in a gauge-symmetries-vector-pack using a harmonic mean
    void harmonically_limit_norms(GaugeSymmetriesVectorPack vector_pack, float max_norm, out GaugeSymmetriesVectorPack result)
    {
        float m0 = length(vector_pack[0]);  result[0] = m0 == 0 ? vector_pack[0] : vector_pack[0] * CommonMath::harmonic_mean(m0, max_norm) / m0;
        float m1 = length(vector_pack[1]);  result[1] = m1 == 0 ? vector_pack[1] : vector_pack[1] * CommonMath::harmonic_mean(m1, max_norm) / m1;
        float m2 = length(vector_pack[2]);  result[2] = m2 == 0 ? vector_pack[2] : vector_pack[2] * CommonMath::harmonic_mean(m2, max_norm) / m2;
        float m3 = length(vector_pack[3]);  result[3] = m3 == 0 ? vector_pack[3] : vector_pack[3] * CommonMath::harmonic_mean(m3, max_norm) / m3;
        float m4 = length(vector_pack[4]);  result[4] = m4 == 0 ? vector_pack[4] : vector_pack[4] * CommonMath::harmonic_mean(m4, max_norm) / m4;
        float m5 = length(vector_pack[5]);  result[5] = m5 == 0 ? vector_pack[5] : vector_pack[5] * CommonMath::harmonic_mean(m5, max_norm) / m5;
        float m6 = length(vector_pack[6]);  result[6] = m6 == 0 ? vector_pack[6] : vector_pack[6] * CommonMath::harmonic_mean(m6, max_norm) / m6;
        float m7 = length(vector_pack[7]);  result[7] = m7 == 0 ? vector_pack[7] : vector_pack[7] * CommonMath::harmonic_mean(m7, max_norm) / m7;
        float m8 = length(vector_pack[8]);  result[8] = m8 == 0 ? vector_pack[8] : vector_pack[8] * CommonMath::harmonic_mean(m8, max_norm) / m8;
        float m9 = length(vector_pack[9]);  result[9] = m9 == 0 ? vector_pack[9] : vector_pack[9] * CommonMath::harmonic_mean(m9, max_norm) / m9;
        float m10 = length(vector_pack[10]); result[10] = m10 == 0 ? vector_pack[10] : vector_pack[10] * CommonMath::harmonic_mean(m10, max_norm) / m10;
        float m11 = length(vector_pack[11]); result[11] = m11 == 0 ? vector_pack[11] : vector_pack[11] * CommonMath::harmonic_mean(m11, max_norm) / m11;
    }
}

#endif