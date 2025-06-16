using System;
using System.Collections.Generic;

namespace FieldForge
{
    public static class DedicatedBuffersConfig
    {
        public class BufferDeclaration
        {
            public string BufferName;
            public Type DataType;
            public Func<SimulationData, int> SizeCalculator;
        }

        // =========================================================================================================

        private static readonly BufferDeclaration[] BLOOM_BUFFER_DECLARATIONS = new[]
        {
            new BufferDeclaration
            {
                BufferName = "bloom_lattice_buffer",
                DataType = typeof(int),
                SizeCalculator = data => (int)(Math.Ceiling(data.simulationWidth / 4.0f) * Math.Ceiling(data.simulationHeight / 4.0f) * Math.Ceiling(data.simulationDepth / 4.0f) * 3) // x0.25x0.25x0.25 the lattice size, x3 rgb channels
            },
            new BufferDeclaration
            {
                BufferName = "bloom_lattice_temp_buffer",
                DataType = typeof(int),
                SizeCalculator = data => (int)(Math.Ceiling(data.simulationWidth / 4.0f) * Math.Ceiling(data.simulationHeight / 4.0f) * Math.Ceiling(data.simulationDepth / 4.0f) * 3) // x0.25x0.25x0.25 the lattice size, x3 rgb channels
            }
        };

        // =========================================================================================================

        public static readonly Dictionary<string, BufferDeclaration[]> ShaderDedicatedBuffers = new()
        {
            ["prepare_rendering-bloom_preparation-add_fermion_norms"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-add_fermion_phases"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-load_fermion_norms"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-load_fermion_phases"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-bloom3"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-bloom6"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-bloom9"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-bloom12"] = BLOOM_BUFFER_DECLARATIONS,
            ["prepare_rendering-bloom_preparation-bloom15"] = BLOOM_BUFFER_DECLARATIONS,
            ["Custom/bloom_rendering_2d"] = BLOOM_BUFFER_DECLARATIONS
        };
    }
}