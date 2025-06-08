/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the gauge potentials within the xy-plane of the simulation by
/// summing over colors whose RGB-channels are set to be proportional to the potentials' vector
/// components at that position.
Shader "Custom/gauge_potentials_rendering_2d"
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
                GaugeSymmetriesVectorPack state;
                FieldInterpolations::get_gauge_state_in_position(position, rend_gauge_potentials_lattice_buffer, state);
                float4 color = float4(0, 0, 0, 0);
                for (int symmetry_index = 0; symmetry_index < 12; symmetry_index++)
                {
                    if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                    float4 field_state = state[symmetry_index];
                    float ampliude = length(field_state);
                    if (ampliude == 0) continue;
                    field_state *= simulation_brightness * (1 - exp(-abs(ampliude))) / ampliude;
                    color += abs(float4(field_state[1], field_state[3], field_state[2], field_state[0]));
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