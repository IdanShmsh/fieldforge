// FieldForge.ComputeManager.cs (Modified to support optional MP4 recording)

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;
using Object = UnityEngine.Object;

namespace FieldForge
{
    public class ComputeManager : IDisposable
    {
        private readonly int _computePasses;
        private readonly ConfigurableShaderEntry<ComputeShader>[] _computeShaders;
        private readonly ConfigurableShaderEntry<Shader>[] _renderShaders;
        private readonly SimulationData _simulationData;
        private readonly RenderTexture _targetTexture;
        private readonly IVideoRecorder _videoRecorder;

        private ComputeBuffers _buffers;
        private Material[] _renderMaterials;
        private RenderTexture _tempTexture1, _tempTexture2;

        private readonly int3 THREAD_GROUP_SIZE = new int3(64, 1, 1);

        private readonly Dictionary<string, GraphicsBuffer> _dedicatedBuffers = new();

        public ComputeManager(SimulationData simulationData, ConfigurableShaderEntry<ComputeShader>[] computeShaders, ConfigurableShaderEntry<Shader>[] renderShaders, int computePasses, RenderTexture targetTexture, IVideoRecorder videoRecorder = null)
        {
            _simulationData = simulationData;
            _computeShaders = computeShaders;
            _renderShaders = renderShaders;
            _computePasses = computePasses;
            _targetTexture = targetTexture;
            _videoRecorder = videoRecorder;
        }

        public CommandBuffer CommandBuffer { get; private set; }

        public void Dispose()
        {
            _buffers.Release();
            foreach (Material material in _renderMaterials) Object.Destroy(material);
            _tempTexture1.Release();
            _tempTexture2.Release();
            _videoRecorder?.Dispose();
            foreach (var buffer in _dedicatedBuffers.Values) buffer?.Release();
            _dedicatedBuffers.Clear();
        }

        public void Initialize()
        {
            InitializeBuffers();
            InitializeMaterials();
            InitializeCommandBuffer();
        }

        private void InitializeBuffers()
        {
            _buffers.FermionFieldPropertiesBuffer = CreateStructuredBuffer(_simulationData.FermionFieldProperties.Length, typeof(FermionFieldProperties));
            _buffers.FermionFieldPropertiesBuffer.SetData(_simulationData.FermionFieldProperties);

            int latticeSize = _simulationData.simulationWidth * _simulationData.simulationHeight * _simulationData.simulationDepth;
            int fermionsBufferSize = latticeSize * _simulationData.FermionFieldProperties.Length;
            int gaugeBufferSize = latticeSize;
            int simulationPokesBufferSize = 16;
            int simulationBarriersBufferSize = 16;
            int fermionModesBufferSize = 1024;
            int globalIntrinsicsBufferSize = 128;

            _buffers.PrevFermionsLatticeBuffer = CreateStructuredBuffer(fermionsBufferSize, typeof(FermionFieldState));
            _buffers.CrntFermionsLatticeBuffer = CreateStructuredBuffer(fermionsBufferSize, typeof(FermionFieldState));
            _buffers.NextFermionsLatticeBuffer = CreateStructuredBuffer(fermionsBufferSize, typeof(FermionFieldState));
            _buffers.RendFermionsLatticeBuffer = CreateStructuredBuffer(fermionsBufferSize, typeof(FermionFieldState));

            _buffers.PrevGaugeLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.CrntGaugeLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.NextGaugeLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.RendGaugeLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));

            _buffers.PrevElectricStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.CrntElectricStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.NextElectricStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.RendElectricStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));

            _buffers.PrevMagneticStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.CrntMagneticStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.NextMagneticStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));
            _buffers.RendMagneticStrengthsLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));

            _buffers.TempFermionsLatticeBuffer = CreateStructuredBuffer(fermionsBufferSize, typeof(FermionFieldState));
            _buffers.TempGaugeLatticeBuffer = CreateStructuredBuffer(gaugeBufferSize, typeof(GaugeSymmetriesVectorPack));

            _buffers.GlobalIntrinsicsBuffer = CreateStructuredBuffer(globalIntrinsicsBufferSize, typeof(int));
            _buffers.SimulationPokesBuffer = CreateStructuredBuffer(simulationPokesBufferSize, typeof(SimulationPokeInformation));
            _buffers.SimulationBarriersBuffer = CreateStructuredBuffer(simulationBarriersBufferSize, typeof(SimulationBarrierInformation));
            _buffers.FermionModesBuffer = CreateStructuredBuffer(fermionModesBufferSize, typeof(FermionModeData));

            // Dedicated buffer creation
            var neededBuffers = new Dictionary<string, DedicatedBuffersConfig.BufferDeclaration>();
            foreach (var computeShader in _computeShaders)
            {
                if (!DedicatedBuffersConfig.ShaderDedicatedBuffers.TryGetValue(computeShader.ShaderItem.name, out var bufferDeclarations)) continue;
                foreach (var decl in bufferDeclarations)
                {
                    if (neededBuffers.ContainsKey(decl.BufferName)) continue;
                    neededBuffers[decl.BufferName] = decl;
                }
            }
            foreach (var renderShader in _renderShaders)
            {
                if (!DedicatedBuffersConfig.ShaderDedicatedBuffers.TryGetValue(renderShader.ShaderItem.name, out var bufferDeclarations)) continue;
                foreach (var decl in bufferDeclarations)
                {
                    if (neededBuffers.ContainsKey(decl.BufferName)) continue;
                    neededBuffers[decl.BufferName] = decl;
                }
            }
            foreach (var kvp in neededBuffers)
            {
                int size = kvp.Value.SizeCalculator(_simulationData);
                var buffer = CreateStructuredBuffer(size, kvp.Value.DataType);
                _dedicatedBuffers[kvp.Key] = buffer;
            }
        }

        private GraphicsBuffer CreateStructuredBuffer(int count, Type type)
        {
            return new GraphicsBuffer(GraphicsBuffer.Target.Structured, count, Marshal.SizeOf(type));
        }

        private void InitializeMaterials()
        {
            _renderMaterials = new Material[_renderShaders.Length];
            for (int i = 0; i < _renderShaders.Length; i++)
            {
                Shader shader = _renderShaders[i].ShaderItem;
                ShaderProperty[] shaderProperties = _renderShaders[i].ShaderProperties;
                var material = new Material(shader);
                ConfigureMaterial(material, shaderProperties);
                _renderMaterials[i] = material;
            }

            _tempTexture1 = new RenderTexture(Screen.width, Screen.height, 0) { enableRandomWrite = true };
            _tempTexture2 = new RenderTexture(Screen.width, Screen.height, 0) { enableRandomWrite = true };
            _tempTexture1.Create();
            _tempTexture2.Create();
        }

        private void InitializeCommandBuffer()
        {
            CommandBuffer = new CommandBuffer { name = "Compute and Render Pass" };

            int3 numberOfThreadGroups = (int3)math.ceil(new float3(_simulationData.simulationWidth, _simulationData.simulationHeight, _simulationData.simulationDepth) / THREAD_GROUP_SIZE);

            for (int i = 0; i < _computePasses; i++)
            {
                foreach (var computeShader in _computeShaders)
                {
                    ComputeShader shaderItem = computeShader.ShaderItem;
                    ShaderProperty[] properties = computeShader.ShaderProperties;

                    int passIndex = 0;
                    while (true)
                    {
                        string kernelName = $"Pass{passIndex}";
                        if (!shaderItem.HasKernel(kernelName)) break;
                        int kernel = shaderItem.FindKernel(kernelName);
                        ConfigureComputeShader(shaderItem, properties, kernel);
                        CommandBuffer.DispatchCompute(shaderItem, kernel, numberOfThreadGroups.x, numberOfThreadGroups.y, numberOfThreadGroups.z);
                        passIndex++;
                    }
                }
            }

            CommandBuffer.Blit(Texture2D.blackTexture, _tempTexture1);

            foreach (Material material in _renderMaterials)
            {
                material.SetTexture("_PreviousTex", _tempTexture1);
                CommandBuffer.Blit(_tempTexture1, _tempTexture2, material);
                (_tempTexture1, _tempTexture2) = (_tempTexture2, _tempTexture1);
            }

            CommandBuffer.Blit(_tempTexture1, _targetTexture);

            if (_videoRecorder != null)
            {
                CommandBuffer.RequestAsyncReadback(_tempTexture1, request =>
                {
                    if (request.hasError) return; // TODO: add an indication
                    if (_videoRecorder == null) return;
                    if (_tempTexture1 == null) return;
                    _videoRecorder.CommitFrame(request, _tempTexture1.width, _tempTexture1.height);
                });
            }
        }

        private void ConfigureComputeShader(ComputeShader shader, ShaderProperty[] properties, int kernel)
        {
            shader.SetInt("simulation_width", _simulationData.simulationWidth);
            shader.SetInt("simulation_height", _simulationData.simulationHeight);
            shader.SetInt("simulation_depth", _simulationData.simulationDepth);
            shader.SetFloat("simulation_temporal_unit", _simulationData.simulationTemporalUnit);
            shader.SetFloat("simulation_spatial_unit", _simulationData.simulationSpatialUnit);
            shader.SetFloat("simulation_non_abelian_self_interaction", _simulationData.simulationNonAbelianSelfInteraction);
            shader.SetFloat("simulation_fermion_density_limit", _simulationData.simulationFermionDensityLimit);
            shader.SetFloat("simulation_gauge_norm_limit", _simulationData.simulationGaugeNormLimit);
            shader.SetFloat("simulation_brightness", _simulationData.simulationBrightness);

            shader.SetBuffer(kernel, "fermion_field_properties", _buffers.FermionFieldPropertiesBuffer);
            shader.SetBuffer(kernel, "simulation_pokes_buffer", _buffers.SimulationPokesBuffer);
            shader.SetBuffer(kernel, "simulation_barriers_buffer", _buffers.SimulationBarriersBuffer);
            shader.SetBuffer(kernel, "fermion_modes_buffer", _buffers.FermionModesBuffer);

            shader.SetBuffer(kernel, "prev_fermions_lattice_buffer", _buffers.PrevFermionsLatticeBuffer);
            shader.SetBuffer(kernel, "crnt_fermions_lattice_buffer", _buffers.CrntFermionsLatticeBuffer);
            shader.SetBuffer(kernel, "next_fermions_lattice_buffer", _buffers.NextFermionsLatticeBuffer);
            shader.SetBuffer(kernel, "rend_fermions_lattice_buffer", _buffers.RendFermionsLatticeBuffer);
            shader.SetBuffer(kernel, "prev_gauge_potentials_lattice_buffer", _buffers.PrevGaugeLatticeBuffer);
            shader.SetBuffer(kernel, "crnt_gauge_potentials_lattice_buffer", _buffers.CrntGaugeLatticeBuffer);
            shader.SetBuffer(kernel, "next_gauge_potentials_lattice_buffer", _buffers.NextGaugeLatticeBuffer);
            shader.SetBuffer(kernel, "rend_gauge_potentials_lattice_buffer", _buffers.RendGaugeLatticeBuffer);
            shader.SetBuffer(kernel, "prev_electric_strengths_lattice_buffer", _buffers.PrevElectricStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "crnt_electric_strengths_lattice_buffer", _buffers.CrntElectricStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "next_electric_strengths_lattice_buffer", _buffers.NextElectricStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "rend_electric_strengths_lattice_buffer", _buffers.RendElectricStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "prev_magnetic_strengths_lattice_buffer", _buffers.PrevMagneticStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "crnt_magnetic_strengths_lattice_buffer", _buffers.CrntMagneticStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "next_magnetic_strengths_lattice_buffer", _buffers.NextMagneticStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "rend_magnetic_strengths_lattice_buffer", _buffers.RendMagneticStrengthsLatticeBuffer);
            shader.SetBuffer(kernel, "temp_fermions_lattice_buffer", _buffers.TempFermionsLatticeBuffer);
            shader.SetBuffer(kernel, "temp_gauge_lattice_buffer", _buffers.TempGaugeLatticeBuffer);
            shader.SetBuffer(kernel, "global_intrinsics", _buffers.GlobalIntrinsicsBuffer);
            foreach (var kvp in _dedicatedBuffers) shader.SetBuffer(kernel, kvp.Key, kvp.Value);

            foreach (var property in properties)
            {
                switch (property.PropertyType)
                {
                    case ShaderPropertyType.Float:
                        shader.SetFloat(property.PropertyName, property.FloatValue);
                        break;
                    case ShaderPropertyType.Vector:
                        shader.SetVector(property.PropertyName, property.VectorValue);
                        break;
                    case ShaderPropertyType.Texture:
                        shader.SetTexture(kernel, property.PropertyName, property.TextureValue);
                        break;
                    case ShaderPropertyType.Matrix:
                        shader.SetMatrix(property.PropertyName, property.MatrixValue);
                        break;
                    case ShaderPropertyType.Int:
                        shader.SetInt(property.PropertyName, property.IntValue);
                        break;
                }
            }
        }

        private void ConfigureMaterial(Material material, ShaderProperty[] properties)
        {
            // Same as before (copy-paste from your previous ConfigureMaterial)
            material.SetInt("simulation_width", _simulationData.simulationWidth);
            material.SetInt("simulation_height", _simulationData.simulationHeight);
            material.SetInt("simulation_depth", _simulationData.simulationDepth);
            material.SetFloat("simulation_temporal_unit", _simulationData.simulationTemporalUnit);
            material.SetFloat("simulation_spatial_unit", _simulationData.simulationSpatialUnit);
            material.SetFloat("simulation_non_abelian_self_interaction", _simulationData.simulationNonAbelianSelfInteraction);
            material.SetFloat("simulation_fermion_density_limit", _simulationData.simulationFermionDensityLimit);
            material.SetFloat("simulation_gauge_norm_limit", _simulationData.simulationGaugeNormLimit);
            material.SetFloat("simulation_brightness", _simulationData.simulationBrightness);
            material.SetBuffer("fermion_field_properties", _buffers.FermionFieldPropertiesBuffer);

            material.SetBuffer("simulation_pokes_buffer", _buffers.SimulationPokesBuffer);
            material.SetBuffer("simulation_barriers_buffer", _buffers.SimulationBarriersBuffer);
            material.SetBuffer("fermion_modes_buffer", _buffers.FermionModesBuffer);

            material.SetBuffer("prev_fermions_lattice_buffer", _buffers.PrevFermionsLatticeBuffer);
            material.SetBuffer("crnt_fermions_lattice_buffer", _buffers.CrntFermionsLatticeBuffer);
            material.SetBuffer("next_fermions_lattice_buffer", _buffers.NextFermionsLatticeBuffer);
            material.SetBuffer("rend_fermions_lattice_buffer", _buffers.RendFermionsLatticeBuffer);
            material.SetBuffer("prev_gauge_potentials_lattice_buffer", _buffers.PrevGaugeLatticeBuffer);
            material.SetBuffer("crnt_gauge_potentials_lattice_buffer", _buffers.CrntGaugeLatticeBuffer);
            material.SetBuffer("next_gauge_potentials_lattice_buffer", _buffers.NextGaugeLatticeBuffer);
            material.SetBuffer("rend_gauge_potentials_lattice_buffer", _buffers.RendGaugeLatticeBuffer);
            material.SetBuffer("prev_electric_strengths_lattice_buffer", _buffers.PrevElectricStrengthsLatticeBuffer);
            material.SetBuffer("crnt_electric_strengths_lattice_buffer", _buffers.CrntElectricStrengthsLatticeBuffer);
            material.SetBuffer("next_electric_strengths_lattice_buffer", _buffers.NextElectricStrengthsLatticeBuffer);
            material.SetBuffer("rend_electric_strengths_lattice_buffer", _buffers.RendElectricStrengthsLatticeBuffer);
            material.SetBuffer("prev_magnetic_strengths_lattice_buffer", _buffers.PrevMagneticStrengthsLatticeBuffer);
            material.SetBuffer("crnt_magnetic_strengths_lattice_buffer", _buffers.CrntMagneticStrengthsLatticeBuffer);
            material.SetBuffer("next_magnetic_strengths_lattice_buffer", _buffers.NextMagneticStrengthsLatticeBuffer);
            material.SetBuffer("rend_magnetic_strengths_lattice_buffer", _buffers.RendMagneticStrengthsLatticeBuffer);
            material.SetBuffer("temp_fermions_lattice_buffer", _buffers.TempFermionsLatticeBuffer);
            material.SetBuffer("temp_gauge_lattice_buffer", _buffers.TempGaugeLatticeBuffer);
            material.SetBuffer("global_intrinsics", _buffers.GlobalIntrinsicsBuffer);
            foreach (var kvp in _dedicatedBuffers) material.SetBuffer(kvp.Key, kvp.Value);

            foreach (var property in properties)
            {
                switch (property.PropertyType)
                {
                    case ShaderPropertyType.Float:
                        material.SetFloat(property.PropertyName, property.FloatValue);
                        break;
                    case ShaderPropertyType.Vector:
                        material.SetVector(property.PropertyName, property.VectorValue);
                        break;
                    case ShaderPropertyType.Texture:
                        material.SetTexture(property.PropertyName, property.TextureValue);
                        break;
                    case ShaderPropertyType.Matrix:
                        material.SetMatrix(property.PropertyName, property.MatrixValue);
                        break;
                    case ShaderPropertyType.Int:
                        material.SetInt(property.PropertyName, property.IntValue);
                        break;
                }
            }
        }

        public void SetFloat(string floatName, float value)
        {
            foreach (var computeShader in _computeShaders) computeShader.ShaderItem.SetFloat(floatName, value);
            foreach (var material in _renderMaterials) material.SetFloat(floatName, value);
        }

        public void SetInt(string intName, int value)
        {
            foreach (var computeShader in _computeShaders) computeShader.ShaderItem.SetInt(intName, value);
            foreach (var material in _renderMaterials) material.SetInt(intName, value);
        }

        public ComputeBuffers GetBuffers()
        {
            return _buffers;
        }

        public void ReleaseResources()
        {
            Dispose();
        }
    }

    public interface IVideoRecorder : IDisposable
    {
        void CommitFrame(AsyncGPUReadbackRequest pixelData, int width, int height);
    }

    public struct ComputeBuffers
    {
        public GraphicsBuffer PrevFermionsLatticeBuffer, CrntFermionsLatticeBuffer, NextFermionsLatticeBuffer, RendFermionsLatticeBuffer, TempFermionsLatticeBuffer;
        public GraphicsBuffer PrevGaugeLatticeBuffer, CrntGaugeLatticeBuffer, NextGaugeLatticeBuffer, RendGaugeLatticeBuffer, TempGaugeLatticeBuffer;
        public GraphicsBuffer PrevElectricStrengthsLatticeBuffer, CrntElectricStrengthsLatticeBuffer, NextElectricStrengthsLatticeBuffer, RendElectricStrengthsLatticeBuffer;
        public GraphicsBuffer PrevMagneticStrengthsLatticeBuffer, CrntMagneticStrengthsLatticeBuffer, NextMagneticStrengthsLatticeBuffer, RendMagneticStrengthsLatticeBuffer;
        public GraphicsBuffer SimulationPokesBuffer, SimulationBarriersBuffer, FermionModesBuffer;
        public GraphicsBuffer FermionFieldPropertiesBuffer;
        public GraphicsBuffer GlobalIntrinsicsBuffer;

        public void Release()
        {
            PrevFermionsLatticeBuffer?.Release();
            CrntFermionsLatticeBuffer?.Release();
            NextFermionsLatticeBuffer?.Release();
            RendFermionsLatticeBuffer?.Release();
            PrevGaugeLatticeBuffer?.Release();
            CrntGaugeLatticeBuffer?.Release();
            NextGaugeLatticeBuffer?.Release();
            RendGaugeLatticeBuffer?.Release();
            PrevElectricStrengthsLatticeBuffer?.Release();
            CrntElectricStrengthsLatticeBuffer?.Release();
            NextElectricStrengthsLatticeBuffer?.Release();
            RendElectricStrengthsLatticeBuffer?.Release();
            PrevMagneticStrengthsLatticeBuffer?.Release();
            CrntMagneticStrengthsLatticeBuffer?.Release();
            NextMagneticStrengthsLatticeBuffer?.Release();
            RendMagneticStrengthsLatticeBuffer?.Release();
            TempFermionsLatticeBuffer?.Release();
            TempGaugeLatticeBuffer?.Release();
            SimulationPokesBuffer?.Release();
            SimulationBarriersBuffer?.Release();
            FermionModesBuffer?.Release();
            FermionFieldPropertiesBuffer?.Release();
            GlobalIntrinsicsBuffer?.Release();
        }
    }
}
