/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the fermion fields within the xy-plane of the simulation by
/// coloring pixels to indicate the spin state of fermions at that position.
/// The screen coordinates are aligned such that the screen boundaries align exactly with the simulation
/// boundaries.
Shader "Custom/fermion_spin_rendering_2d"
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
            #include "../../../src/visuals/fermion_renderers/render_fermion_spin_dial.hlsl"

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
                half3 position = half3(i.uv.x * (half)simulation_width, i.uv.y * (half)simulation_height, 0);
                half4 color = half4(0, 0, 0, 0);
                for (int field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
                {
                    color += FermionRendering::RenderFermionSpinDial::get_fermion_spin_dial_color_at_position(position, field_index, granularity, length_scale);
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