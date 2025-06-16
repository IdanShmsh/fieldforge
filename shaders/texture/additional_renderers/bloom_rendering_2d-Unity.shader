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

            uint get_bloom_buffer_index(uint3 bloom_lattice_position, uint color_channel)
            {
                uint3 bloom_lattice_size = uint3((simulation_width + 3) / 4, (simulation_height + 3) / 4, (simulation_depth + 3) / 4);
                uint index = ((color_channel * bloom_lattice_size.z + bloom_lattice_position.z) * bloom_lattice_size.y +  bloom_lattice_position.y) * bloom_lattice_size.x + bloom_lattice_position.x;
                return index;
            }

            void collect_corner_colors(float3 bloom_lattice_position, out float3 colors[4])
            {
                float3 bloom_lattice_size = float3((simulation_width + 3) / 4, (simulation_height + 3) / 4, (simulation_depth + 3) / 4);
                colors[0] = float3(0, 0, 0);
                colors[1] = float3(0, 0, 0);
                colors[2] = float3(0, 0, 0);
                colors[3] = float3(0, 0, 0);
                float3 floor_position = floor(bloom_lattice_position);
                floor_position = clamp(floor_position, float3(0, 0, 0), bloom_lattice_size - 1);
                float3 ceil_position = ceil(bloom_lattice_position);
                ceil_position = clamp(ceil_position, float3(0, 0, 0), bloom_lattice_size - 1);
                uint lattice_index = 0;
                for (uint color_channel = 0; color_channel < 3; color_channel++)
                {
                    lattice_index = get_bloom_buffer_index(uint3(floor_position.x, floor_position.y, floor_position.z), color_channel);
                    colors[0][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = get_bloom_buffer_index(uint3(floor_position.x, ceil_position.y, floor_position.z), color_channel);
                    colors[1][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = get_bloom_buffer_index(uint3(ceil_position.x, floor_position.y, floor_position.z), color_channel);
                    colors[2][color_channel] = (float)bloom_lattice_buffer[lattice_index] / 255.0f;
                    lattice_index = get_bloom_buffer_index(uint3(ceil_position.x, ceil_position.y, floor_position.z), color_channel);
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