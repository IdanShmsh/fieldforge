/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the fermion fields within the xy-plane of the simulation by
/// coloring pixels as a linear combination of the colors representing the fermion fields' phases (via hue) and
/// norms (via brightness) tinted by colors configured to each fermion field.
/// Lattice positions are interpolated to pixel coordinates.
/// The screen coordinates are aligned such that the screen boundaries align exactly with the simulation
/// boundaries.
Shader "Custom/fermion_phases_and_norms_rendering_2d"
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

            #include "../../../src/visuals/fermion_renderers/render_fermion_phase.hlsl"
            #include "../../../src/visuals/fermion_renderers/render_fermion_norm.hlsl"

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

            half4 frag(v2f i) : SV_Target
            {
                brightness = brightness ? brightness : 1.0;
                opacity = opacity ? opacity : 1.0;
                half3 position = half3(i.uv.x * (half)simulation_width, i.uv.y * (half)simulation_height, 0);
                half4 color = half4(0, 0, 0, 0);
                for (int field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
                {
                    color += FermionRendering::RenderFermionPhase::get_fermion_phase_color_at_position(position, field_index);
                    color += FermionRendering::RenderFermionNorm::get_fermion_norm_color_at_position(position, field_index);
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
