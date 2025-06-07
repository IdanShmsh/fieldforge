/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the gauge potentials within the xy-plane of the simulation by
/// coloring pixels to indicate dials pointing along the electric fields' vector directions.
Shader "Custom/gauge_electric_vector_field_rendering_2d"
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

            float4 frag(v2f i) : SV_Target
            {
                float3 position = float3(i.uv.x * (float)simulation_width, i.uv.y * (float)simulation_height, 0);
                float4 rendered_color = tex2D(_PreviousTex, i.uv);
                float4 color = float4(0, 0, 0, 0);
                float3 rounded_position = round(position);
                float3 delta_position = position - rounded_position;
                float offset = length(delta_position);
                if (offset == 0) return float4(0, 0, 0, 0);
                uint buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(rounded_position);
                GaugeSymmetriesVectorPack state = rend_electric_strengths_lattice_buffer[buffer_index];
                for (int symmetry_index = 0; symmetry_index < 12; symmetry_index++)
                {
                    if (!SimulationDataOps::is_gauge_field_active(symmetry_index)) continue;
                    float4 field_state = state[symmetry_index];
                    field_state[0] = 0;
                    float field_state_length = length(field_state);
                    if (field_state_length == 0) continue;
                    field_state *= 25 / field_state_length;
                    float cross_product = length(cross(field_state.yzw, delta_position));
                    float3 symmetry_color = CommonMath::hsv2rgb(float3(symmetry_index / 12.0f, 0.5f, 1));
                    color += field_state_length * float4(symmetry_color, 1) * exp(-cross_product * cross_product) * sqrt(max(0.25 - offset * offset, 0));
                }
                color[3] = 1;
                saturate(color);
                return rendered_color + color;
            }
            ENDCG
        }
    }
    FallBack Off
}