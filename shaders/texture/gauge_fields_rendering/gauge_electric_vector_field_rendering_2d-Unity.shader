/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the gauge electric within the xy-plane of the simulation by
/// coloring pixels to indicate dials pointing along the fields' vector potential directions.
Shader "Custom/gauge_electric_vector_field_rendering_2d"
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
            #include "../../../src\visuals\gauge_renderers\render_gauge_vectors_dials.hlsl"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            half brightness = 1.0;
            half opacity = 1.0;
            half granularity = 1.0;
            half length_scale = 1.0;

            half4 frag(v2f i) : SV_Target
            {
                brightness = brightness ? brightness : 1.0;
                opacity = opacity ? opacity : 1.0;
                granularity = granularity ? granularity : 1.0;
                length_scale = length_scale ? length_scale : 1.0;
                half4 color = half4(0, 0, 0, 0);
                half3 position = half3(i.uv.x * (half)simulation_width, i.uv.y * (half)simulation_height, 0);
                color += GaugeRendering::RenderGaugeVectorsDials::get_gauge_vectors_dial_color_at_position_xy(rend_electric_strengths_lattice_buffer, position, granularity, length_scale);
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