using System;
using UnityEngine;

namespace FieldForge
{
    [Serializable]
    public class ConfigurableShaderEntry<T>
    {
        [SerializeField] public T ShaderItem;
        [SerializeField] public ShaderProperty[] ShaderProperties;

        static ConfigurableShaderEntry()
        {
            if (typeof(T) != typeof(Shader) && typeof(T) != typeof(ComputeShader))
            {
                throw new InvalidOperationException(
                    $"Type parameter T must be either Shader or ComputeShader. Provided type: {typeof(T)}"
                );
            }
        }
    }

    [Serializable]
    public class ShaderProperty
    {
        [SerializeField] public string PropertyName;
        [SerializeField] public ShaderPropertyType PropertyType;

        // TODO - Display only the relevant fields in the inspector based on PropertyType
        [SerializeField] public float FloatValue;
        [SerializeField] public Vector4 VectorValue;
        [SerializeField] public Color ColorValue;
        [SerializeField] public Texture TextureValue;
        [SerializeField] public Matrix4x4 MatrixValue;
        [SerializeField] public int IntValue;
    }

    [Serializable]
    public enum ShaderPropertyType
    {
        Float,
        Vector,
        Texture,
        Matrix,
        Int,
    }
}