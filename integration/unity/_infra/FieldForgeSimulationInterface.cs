using System;
using Unity.Collections;
using UnityEngine;

namespace FieldForge
{
    [Serializable]
    public class SimulationInterface
    {
        [SerializeField] public RenderTexture targetTexture;
        [SerializeField, Min(1)] public uint computePasses = 1;
        [SerializeField] public ConfigurableShaderEntry<ComputeShader>[] computeShaders;
        [SerializeField] public ConfigurableShaderEntry<Shader>[] renderShaders;
        [SerializeField] public SimulationData simulationData = new SimulationData(){
            simulationWidth = 128,
            simulationHeight = 128,
            simulationDepth = 0,
            simulationTemporalUnit = 0.05f,
            simulationSpatialUnit = 0.1f,
            simulationNonAbelianSelfInteraction = 0.1f,
            simulationFermionDensityLimit = 10.0f,
            simulationGaugeNormLimit = 10.0f,
            simulationBrightness = 1.0f,
            FermionFieldProperties = new FermionFieldProperties[8]
            {
                new FermionFieldProperties
                {
                    color = Color.red,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.green,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.blue,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.yellow,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.cyan,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.magenta,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.white,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                },
                new FermionFieldProperties
                {
                    color = Color.black,
                    fieldMass = 1.0f,
                    U1InteractionCoupling = 0.1f,
                    SU2InteractionCoupling = 0.1f,
                    SU3InteractionCoupling = 0.1f
                }
            }
        };

        [SerializeField] public SerializableFieldsMask fieldsMask;
    }
}
