/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the gauge magnetic within the xy-plane of the simulation by
/// coloring pixels to indicate dials pointing along the fields' vector potential directions.
Shader "Custom/gauge_magnetic_vector_field_rendering_2d"
{
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            Blend One One
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
            
            float brightness = 1.0;
            float opacity = 1.0;
            float granularity = 1.0;
            float length_scale = 1.0;

            float4 frag(v2f i) : SV_Target
            {
                brightness = brightness ? brightness : 1.0;
                opacity = opacity ? opacity : 1.0;
                granularity = granularity ? granularity : 1.0;
                length_scale = length_scale ? length_scale : 1.0;
                float4 color = float4(0, 0, 0, 0);
                float3 position = float3(i.uv.x * (float)simulation_width, i.uv.y * (float)simulation_height, 0);
                float3 rounded_position = round(position / granularity) * granularity;
                float2 delta_position = (position.xy - rounded_position.xy) / granularity;
                float2 cell_dimensions = _ScreenParams.xy / float2(simulation_width, simulation_height) * granularity;
                float2 offset_coefficient = delta_position.xy / cell_dimensions;
                uint buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(rounded_position);
                GaugeSymmetriesVectorPack state = rend_magnetic_strengths_lattice_buffer[buffer_index];
                for (int symmetry_index = 0; symmetry_index < 12; symmetry_index++)
                {
                    if (!SimulationDataOps::is_gauge_symmetry_active(symmetry_index)) continue;
                    float4 field_state = state[symmetry_index];
                    field_state[0] = 0;
                    float field_state_length = length(field_state);
                    if (field_state_length == 0) continue;
                    float4 normalized_field_state = field_state / field_state_length;
                    float limited_length = CommonMath::harmonic_mean(field_state_length / length_scale, 1);
                    float cross_product = length(cross(normalized_field_state.yzw, float3(offset_coefficient, 0)));
                    float dot_product = max(dot(normalized_field_state.yz, offset_coefficient), 0);
                    float3 symmetry_color = CommonMath::hsv2rgb(float3(symmetry_index / 12.0f, 0.5f, 1));
                    float orthogonal_color_factor = exp(-cross_product * cross_product / (0.001 * 0.001));
                    float parallel_color_factor = sqrt(max(0, 1 - pow((2 * dot_product - limited_length) / limited_length, 4)));
                    float circular_falloff = sqrt(max(0.25 - dot(delta_position, delta_position), 0));
                    float total_color_factor = orthogonal_color_factor * parallel_color_factor * circular_falloff;
                    color += float4(symmetry_color, 1) * total_color_factor * sqrt(field_state_length);
                }
                color *= simulation_brightness;
                color *= brightness;
                color[3] = opacity;
                return color;
            }
            ENDCG
        }
    }
    FallBack Off
}