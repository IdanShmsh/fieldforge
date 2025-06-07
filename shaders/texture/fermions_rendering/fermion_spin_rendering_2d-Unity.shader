/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the fermion fields within the xy-plane of the simulation by
/// coloring pixels to indicate the spin state of fermions at that position.
/// The screen coordinates are aligned such that the screen boundaries align exactly with the simulation
/// boundaries.
Shader "Custom/fermion_spin_rendering_2d"
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
                if (offset == 0) return rendered_color;
                for (int field_index = 0; field_index < FERMION_FIELDS_COUNT; field_index++)
                {
                    if (!SimulationDataOps::is_fermion_field_active(field_index)) continue;
                    FermionFieldProperties field_properties = fermion_field_properties[field_index];
                    uint buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(rounded_position, field_index);
                    FermionFieldState fermion_state = rend_fermions_lattice_buffer[buffer_index];
                    float3 fermion_spin_state = DiracFormalism::obtain_spin_state(fermion_state);
                    float spin_state_norm = length(fermion_spin_state);
                    if (spin_state_norm == 0) return float4(0, 0, 0, 0);
                    fermion_spin_state *= 25 / spin_state_norm;
                    float cross_product = length(cross(fermion_spin_state, delta_position));
                    color += simulation_brightness * field_properties.color * spin_state_norm * exp(-cross_product * cross_product) * sqrt(max(0.25 - offset * offset, 0));
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