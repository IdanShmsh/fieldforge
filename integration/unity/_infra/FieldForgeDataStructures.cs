using System;
using Unity.Mathematics;
using UnityEngine;

namespace FieldForge
{
    [Serializable]
    public struct SimulationData
    {
        [Min(1)] public int simulationWidth;
        [Min(1)] public int simulationHeight;
        [Min(1)] public int simulationDepth;
        [Min(0f)] public float simulationTemporalUnit;
        [Min(0f)] public float simulationSpatialUnit;
        [Min(0f)] public float simulationNonAbelianSelfInteraction;
        [Min(0.00001f)] public float simulationFermionDensityLimit;
        [Min(0.00001f)] public float simulationGaugeNormLimit;
        [Min(0f)] public float simulationBrightness;
        public FermionFieldProperties[] FermionFieldProperties;
    }

    [Serializable]
    public struct FermionFieldProperties
    {
        public Color color;
        [Min(0.01f)] public float fieldMass;
        public float U1InteractionCoupling;
        [Min(0f)] public float SU2InteractionCoupling;
        [Min(0f)] public float SU3InteractionCoupling;
    }

    public struct FermionFieldState
    {
        public float2 h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11;
    }

    public struct GaugeSymmetriesVectorPack
    {
        public float h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h40, h41, h42, h43, h44, h45, h46, h47;
    }

    public struct SimulationPokeInformation
    {
        public int pokeStrength, pokeRadius, x, y, z, dx, dy, dz, pokeMask;
    }

    public struct SimulationBarrierInformation
    {
        public int barrierStrength, barrierWidth, barrierRadius, p1_x, p1_y, p1_z, p2_x, p2_y, p2_z, barrierMask;
    }

    public struct FermionModeData
    {
        public float fieldIndex, amplitude, originX, originY, originZ ,waveVectorX, waveVectorY, waveVectorZ, spinStateX, spinStateY, spinStateZ, inverseGaussianWidthX, inverseGaussianWidthY, inverseGaussianWidthZ;
    }
}
