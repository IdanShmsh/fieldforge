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

        public static readonly Dictionary<string, BufferDeclaration[]> ShaderDedicatedBuffers = new()
        {
        };

    }
}