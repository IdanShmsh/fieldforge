/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the fermion fields within the xy-plane of the simulation by
/// coloring pixels as a linear combination of the colors representing the fermion fields' phases (via hue) and
/// norms (via brightness) tinted by colors configured to each fermion field.
/// Lattice positions are interpolated to pixel coordinates.
/// The screen coordinates are aligned such that the screen boundaries align exactly with the simulation
/// boundaries.
Shader "Custom/fermion_phases_rendering_2d"
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

            #include "../../../src/visuals/fermion_field_coloring.hlsl"

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
                float4 color = rendered_color;
                color += FermionFieldColoring::compute_fermion_fields_phase_color(position, rend_fermions_lattice_buffer);
                color[3] = 1;
                return color;
            }
            ENDCG
        }
    }
    FallBack Off
}