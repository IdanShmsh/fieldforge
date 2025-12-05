using System;
using UnityEditor;
using UnityEngine;

namespace FieldForge
{
    public class FermionModesInjection : SimulationInteractiveBehavior
    {
        [SerializeField] private Vector3 origin;
        [SerializeField, Min(0)] private int fieldIndex;
        [SerializeField] private float amplitude;
        [SerializeField] private Vector3 size;
        [SerializeField] private Vector3 waveVector;
        [SerializeField] private Vector3 spinState;
        [SerializeField] private bool submit;

        private SimulationData simulationData;

        private void Start()
        {
            simulationData = simulationManager.simulationInterface.simulationData;
        }

        private void Update()
        {
            if (submit) {
                submit = false;
                SubmitMode();
            }
        }

        public void SetOrigin(Vector3 v)
        {
            origin = v;
        }

        public void SetSize(Vector3 v)
        {
            size = v;
        }

        public void SetAmplitude(float v)
        {
            amplitude = v;
        }

        public void SetWaveVector(Vector3 v)
        {
            waveVector = v;
        }

        public void SetSpinState(Vector3 v)
        {
            spinState = v;
        }

        public void SubmitMode()
        {
            Vector3 originalOrigin = origin;
            int originalFieldIndex = fieldIndex;
            Vector3 originalSize = size;
            Vector3 maxBounds = new Vector3(simulationData.simulationWidth, simulationData.simulationHeight, simulationData.simulationDepth);

            origin = Vector3.Max(Vector3.zero, Vector3.Min(origin, maxBounds));
            fieldIndex = Mathf.Min(simulationData.FermionFieldProperties.Length, fieldIndex);
            size = Vector3.Max(Vector3.zero, Vector3.Min(size, maxBounds));

            if (origin != originalOrigin) Debug.LogWarning("Origin was clamped to simulation bounds.");
            if (fieldIndex != originalFieldIndex) Debug.LogWarning("Field Index was clamped to available fields.");
            if (size != originalSize) Debug.LogWarning("Size was clamped to simulation bounds.");

            float invX = size.x == 0f ? 0f : 1f / size.x;
            float invY = size.y == 0f ? 0f : 1f / size.y;
            float invZ = size.z == 0f ? 0f : 1f / size.z;

            simulationManager.FermionModesManager.SubmitFermionMode(
                new FermionModeData
                {
                    amplitude = amplitude,
                    fieldIndex = fieldIndex + 1,
                    originX = origin.x,
                    originY = origin.y,
                    originZ = origin.z,
                    spinStateX = spinState.x,
                    spinStateY = spinState.y,
                    spinStateZ = spinState.z,
                    waveVectorX = waveVector.x,
                    waveVectorY = waveVector.y,
                    waveVectorZ = waveVector.z,
                    inverseGaussianWidthX = invX,
                    inverseGaussianWidthY = invY,
                    inverseGaussianWidthZ = invZ
                }
            );
        }
    }
}