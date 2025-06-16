/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the bloom effect encoded in its dedicated buffer in 2D.
/// For this to be relevant the bloom preparation compute operation must be ran beforehand.
Shader "Custom/bloom_rendering_2d"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define SPATIAL_DIMENSIONALITY 3

            #include "../../../src/core/analysis/field_interpolations.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _PreviousTex;
            StructuredBuffer<int> bloom_lattice_buffer;

            void collect_corner_colors(float3 bloom_lattice_position, out float3 colors[4])
            {
                colors[0] = float3(0, 0, 0);
                colors[1] = float3(0, 0, 0);
                colors[2] = float3(0, 0, 0);
                colors[3] = float3(0, 0, 0);
                float3 bloom_lattice_size = ceil(float3(simulation_width, simulation_height, simulation_depth) / 4.0f);
                float3 floor_position = floor(bloom_lattice_position);
                float3 ceil_position = ceil(bloom_lattice_position);
                uint lattice_index = 0;
                [unroll] for (uint color_channel = 0; color_channel < 3; color_channel++)
                {
                    lattice_index = (uint)(((color_channel * bloom_lattice_size.z + floor_position.z) * bloom_lattice_size.y + floor_position.y) * bloom_lattice_size.x + floor_position.x);
                    colors[0][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = (uint)(((color_channel * bloom_lattice_size.z + floor_position.z) * bloom_lattice_size.y + ceil_position.y) * bloom_lattice_size.x + floor_position.x);
                    colors[1][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = (uint)(((color_channel * bloom_lattice_size.z + floor_position.z) * bloom_lattice_size.y + floor_position.y) * bloom_lattice_size.x + ceil_position.x);
                    colors[2][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = (uint)(((color_channel * bloom_lattice_size.z + floor_position.z) * bloom_lattice_size.y + ceil_position.y) * bloom_lattice_size.x + ceil_position.x);
                    colors[3][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                }
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 position = float3(i.uv.x * (float)simulation_width / 4.0f, i.uv.y * (float)simulation_height / 4.0f, 0);
                float4 rendered_color = tex2D(_PreviousTex, i.uv);
                float4 color = float4(0, 0, 0, 1);
                float3 corner_colors[4];
                collect_corner_colors(position, corner_colors);
                CommonMath::interpolate_2d(position - floor(position), corner_colors, color.xyz);
                return rendered_color + color;
            }
            ENDCG
        }
    }
    FallBack Off
}