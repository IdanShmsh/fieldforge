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
            if (simulationManager == null)
            {
                Debug.LogError("[FieldForge] No simulation manager found. Attach to a simulation manager.");
                Destroy(this);
                return;
            }
        }

        void OnEnable()
        {
            awakeTime++;
        }

        private void Update()
        {
            
        }
    }
}