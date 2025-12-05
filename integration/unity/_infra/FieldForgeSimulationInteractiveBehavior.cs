using System;
using UnityEngine;

namespace FieldForge
{
    public class SimulationInteractiveBehavior : MonoBehaviour
    {
        [SerializeField] protected UnitySimulationManager simulationManager;

        protected int awakeTime = 0;

        void Awake()
        {
            EnsureSimulationManager();
        }

        void OnEnable()
        {
            awakeTime++;
        }

        private void EnsureSimulationManager()
        {
            if (simulationManager) return;
            Debug.LogError("[FieldForge] No simulation manager found. Attach to a simulation manager.");
            Destroy(this);
        }
    }
}