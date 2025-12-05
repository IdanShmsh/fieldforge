/// -----------------------------------------------------------------------------------------------
/// This shader performs a single rendering operation in FieldForge's configurable render-pipeline.
/// -----------------------------------------------------------------------------------------------
/// This pipeline operation renders the sparks effect encoded in its dedicated buffer in 2D.
/// For this to be relevant the sparks preparation compute operation must be ran beforehand.
Shader "Custom/sparks_rendering_2d"
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

            StructuredBuffer<uint> sparks_lattice_buffer;

            uint get_sparks_buffer_index(uint3 sparks_lattice_position)
            {
                uint3 sparks_lattice_size = uint3(simulation_width, simulation_height, simulation_depth);
                uint index = (sparks_lattice_position.z * sparks_lattice_size.y +  sparks_lattice_position.y) * sparks_lattice_size.x + sparks_lattice_position.x;
                return index;
            }

            void collect_corner_shades(half3 sparks_lattice_position, out half4 shades)
            {
                shades[0] = 0;
                shades[1] = 0;
                shades[2] = 0;
                shades[3] = 0;
                half3 sparks_lattice_size = half3(simulation_width, simulation_height, simulation_depth);
                half3 floor_position = floor(sparks_lattice_position);
                floor_position = clamp(floor_position, half3(0, 0, 0), sparks_lattice_size - 1);
                half3 ceil_position = ceil(sparks_lattice_position);
                ceil_position = clamp(ceil_position, half3(0, 0, 0), sparks_lattice_size - 1);
                uint lattice_index = get_sparks_buffer_index(uint3(floor_position.x, floor_position.y, floor_position.z));
                shades[0] = sparks_lattice_buffer[lattice_index] / 127.0f;
                lattice_index = get_sparks_buffer_index(uint3(floor_position.x, ceil_position.y, floor_position.z));
                shades[1] = sparks_lattice_buffer[lattice_index] / 127.0f;
                lattice_index = get_sparks_buffer_index(uint3(ceil_position.x, floor_position.y, floor_position.z));
                shades[2] = sparks_lattice_buffer[lattice_index] / 127.0f;
                lattice_index = get_sparks_buffer_index(uint3(ceil_position.x, ceil_position.y, floor_position.z));
                shades[3] = sparks_lattice_buffer[lattice_index] / 127.0f;
            }

            half sparkle_corner_profile(half3 position_fraction)
            {
                return (1 - position_fraction.x) * (1 - position_fraction.y) / CommonMath::integer_pow(1 + position_fraction.x * position_fraction.y, 8);
            }

            half sparkle_shade(half3 position_fraction, half4 corner_shades)
            {
                half shade = 0;
                shade += corner_shades[0] * sparkle_corner_profile(position_fraction);
                position_fraction.y = 1 - position_fraction.y;
                shade += corner_shades[1] * sparkle_corner_profile(position_fraction);
                position_fraction.x = 1 - position_fraction.x;
                shade += corner_shades[3] * sparkle_corner_profile(position_fraction);
                position_fraction.y = 1 - position_fraction.y;
                shade += corner_shades[2] * sparkle_corner_profile(position_fraction);
                return shade;
            }

            half brightness = 1.0;
            half opacity = 1.0;

            half4 frag(v2f i) : SV_Target
            {
                brightness = brightness ? brightness : 1.0;
                opacity = opacity ? opacity : 1.0;
                half3 position = half3(i.uv.x * simulation_width, i.uv.y * simulation_height, 0);
                half4 corner_shades;
                collect_corner_shades(position, corner_shades);
                corner_shades = CommonMath::harmonic_mean(corner_shades, half4(1,1,1,1));
                half3 fraction = abs(position - floor(position));
                half4 color = half4(1, 1, 1, 1) * sparkle_shade(fraction, corner_shades);
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