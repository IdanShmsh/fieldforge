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
                for (int field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
                {
                    if (!SimulationDataOps::is_fermion_field_active(field_index)) continue;
                    FermionFieldProperties field_properties = fermion_field_properties[field_index];
                    FermionFieldState state;
                    FieldInterpolations::get_fermion_state_in_position(position, field_index, rend_fermions_lattice_buffer, state);
                    float state_norm = FermionFieldStateMath::norm(state);
                    float state_phase = ComplexNumbersMath::phase(state[0]);
                    float3 hsv = float3(state_phase / (2.0 * 3.14159265), 1.0, state_norm);
                    color += float4(CommonMath::hsv2rgb(hsv) * simulation_brightness, 0);
                    color += field_properties.color * state_norm * state_norm * simulation_brightness;
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