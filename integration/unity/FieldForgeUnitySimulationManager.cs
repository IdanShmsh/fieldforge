using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

namespace FieldForge
{
    /// <summary>
    /// The main component for managing the FieldForge simulation in Unity.
    /// Required to be attached to a camera (to which a command buffer is added).
    /// Includes minimum configurations interface available in the Unity editor GUI.
    /// Manages all essential bindings with the hlsl simulation given a provided pipeline.
    /// Executes and manages executing and rendering the simulation (as configured).
    /// Provides entry points and technical interface for any component externally interacting with the simulation.
    /// </summary>
    public class UnitySimulationManager : MonoBehaviour
    {
        [SerializeField] public SimulationInterface simulationInterface;
        [SerializeField] public string globalVideoRecordingOutputPath = "";

        private ComputeManager _computeManager;
        private PokesManager _pokesManager;
        private BarriersManager _barriersManager;

        private void Start()
        {
            SetupComputeManager();
            SetupPokesManager();
            SetupBarriersManager();
            LoadCommandBuffer();
            _computeManager.SetInt("simulation_field_mask", simulationInterface.fieldsMask.Binary);
        }

        private void Update()
        {
            _pokesManager.ApplyPokes();
            _barriersManager.ApplyBarriers();
        }

        public ComputeManager ComputeManager => _computeManager;
        public PokesManager PokesManager => _pokesManager;
        public BarriersManager BarriersManager => _barriersManager;

        private void OnDestroy()
        {
            Debug.Log("[FieldForge] Destroying UnitySimulationManager.");
            if (_computeManager != null) _computeManager.ReleaseResources();
        }

        private void SetupComputeManager()
        {
            IVideoRecorder videoRecorder = ConstructVideoRecorder();
            _computeManager = new ComputeManager(
                simulationInterface.simulationData,
                simulationInterface.computeShaders,
                simulationInterface.renderShaders,
                (int)simulationInterface.computePasses,
                simulationInterface.targetTexture,
                videoRecorder
            );
            _computeManager.Initialize();
        }

        private IVideoRecorder ConstructVideoRecorder()
        {
            if (globalVideoRecordingOutputPath.Length <= 0) return null;
            Debug.Log("[FieldForge] Initializing video recorder. Recording to: " + globalVideoRecordingOutputPath);
            int framerate = Math.Max((int)(1 / simulationInterface.simulationData.simulationTemporalUnit), 1);
            return new FfmpegVideoRecorder(globalVideoRecordingOutputPath, Screen.width, Screen.height, framerate);
        }

        private void SetupPokesManager()
        {
            _pokesManager = new PokesManager(_computeManager);
        }

        private void SetupBarriersManager()
        {
            _barriersManager = new BarriersManager(_computeManager);
        }

        private void LoadCommandBuffer()
        {
            var targetCamera = GetComponent<Camera>();
            if (!targetCamera) throw new Exception("[FieldForge] No camera component found. Attach to a camera.");
            targetCamera.AddCommandBuffer(CameraEvent.AfterEverything, _computeManager.CommandBuffer);
        }
    }
}
