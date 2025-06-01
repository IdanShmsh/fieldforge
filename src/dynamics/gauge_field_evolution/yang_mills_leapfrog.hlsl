#ifndef GAUGE_FIELD_EVOLUTION_YANG_MILLS_LEAPFROG
#define GAUGE_FIELD_EVOLUTION_YANG_MILLS_LEAPFROG

#include "../../core/formalisms/yang_mills_formalism.hlsl"
#include "../../core/formalisms/gauge_interaction.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/global_intrinsics_indieces.hlsl"

const float electric_divergence_cleaning_factor = 0.3;

namespace GaugeFieldsEvolution
{
    /// The implementation of a Yang-Mills leapfrog evolution of gauge fields.
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace YangMillsLeapfrog
    {
        // A structure used to cache processed data necessary for performing the evolution
        struct EvolutionCache
        {
            float3 position;
            uint lattice_buffer_index;
            GaugeSymmetriesVectorPack prev_gauge_potentials;
            GaugeSymmetriesVectorPack prev_electric_strengths;
            GaugeSymmetriesVectorPack crnt_gauge_potentials;
            GaugeSymmetriesVectorPack crnt_electric_strengths;
            GaugeSymmetriesVectorPack crnt_magnetic_strengths;
            GaugeFieldsJacobian gauge_potential_jacobians;
            GaugeFieldStrength gauge_field_strength_tensor;
            GaugeFieldsDivergence prev_electric_strength_divergences;
            GaugeSymmetriesVectorPack magnetic_strength_curls;
            GaugeSymmetriesVectorPack total_gauge_currents;
        };

        // Obtain data needed to perform the evolution
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        void _obtain_evolution_data(float3 position, out EvolutionCache evolution_data)
        {
            // The position and the buffer index associated with it are cached
            evolution_data.position = position;
            evolution_data.lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);

            // The field states are obtained and cached
            evolution_data.prev_gauge_potentials = prev_gauge_potentials_lattice_buffer[evolution_data.lattice_buffer_index];
            evolution_data.prev_electric_strengths = prev_electric_strengths_lattice_buffer[evolution_data.lattice_buffer_index];
            evolution_data.crnt_gauge_potentials = crnt_gauge_potentials_lattice_buffer[evolution_data.lattice_buffer_index];
            evolution_data.crnt_electric_strengths = crnt_electric_strengths_lattice_buffer[evolution_data.lattice_buffer_index];
            evolution_data.crnt_magnetic_strengths = crnt_magnetic_strengths_lattice_buffer[evolution_data.lattice_buffer_index];

            // The Jacobian of the field state is computed - used to compute the field strength tensor and the divergence of the field
            GaugeSymmetriesVectorPackDifferentials::jacobian(position, evolution_data.gauge_potential_jacobians);

            // The field strength tensor is computed - used to compute the slope of the electric field and computes the magnetic field
            YangMillsFormalism::field_strength_tensor(evolution_data.crnt_gauge_potentials, evolution_data.gauge_potential_jacobians, evolution_data.gauge_field_strength_tensor);

            // The divergence of the electric field is computed for divergence cleaning
            GaugeSymmetriesVectorPackDifferentials::divergence(position, prev_electric_strengths_lattice_buffer, evolution_data.prev_electric_strength_divergences);

            // The curl of the electric and magnetic fields are computed for their own evolution
            GaugeSymmetriesVectorPackDifferentials::curl(position, crnt_magnetic_strengths_lattice_buffer, evolution_data.magnetic_strength_curls);

            // Obtain the current at the position
            GaugeInteraction::compute_total_gauge_currents_at_position(evolution_data.position, evolution_data.total_gauge_currents);
        }

        // Evolve the electric gauge field given the evolution data
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        void _electric_strengths_evolution(EvolutionCache evolution_data, out GaugeSymmetriesVectorPack next_electric_strengths)
        {
            GaugeSymmetriesVectorPack electric_strength_temporal_slope;

            // Sum the total gauge currents and the magnetic curls to get the slope of the electric field
            GaugeSymmetriesVectorPackMath::sum(evolution_data.total_gauge_currents, evolution_data.magnetic_strength_curls, electric_strength_temporal_slope);

            // Self-interaction
            if (simulation_non_abelian_self_interaction)
            {
                for (uint mu = 0; mu < 4; mu++)
                {
                    GaugeSymmetriesVectorPack mu_field_strength_column;
                    YangMillsFormalism::field_strength_column(evolution_data.gauge_field_strength_tensor, mu, mu_field_strength_column);
                    for (uint a = 0; a < 12; a++)
                    {
                        if (!SimulationDataOps::is_gauge_field_active(a)) continue;
                        for (uint n = 0; n < 4; n++) electric_strength_temporal_slope[a][mu] -= YangMillsFormalism::gauge_commutator(evolution_data.crnt_gauge_potentials, mu_field_strength_column, a, 0, n);
                    }
                }
            }

            // Weighing the slope with the temporal unit (\Delta t)
            GaugeSymmetriesVectorPackMath::scl(electric_strength_temporal_slope, 2 * simulation_temporal_unit, electric_strength_temporal_slope);

            // Then, adding it to the previous state to get the next state (leap frog method).
            GaugeSymmetriesVectorPackMath::sum(evolution_data.prev_electric_strengths, electric_strength_temporal_slope, next_electric_strengths);

            // Perform divergence cleaning on the electric field
            float4 cleaning_direction;
            int cleaning_axis = global_intrinsics[GI_FRAME_COUNT] % SPATIAL_DIMENSIONALITY;
            if (cleaning_axis == 0) cleaning_direction = float4(0, 1, 0, 0);
            else if (cleaning_axis == 1) cleaning_direction = float4(0, 0, 1, 0);
            else cleaning_direction = float4(0, 0, 0, 1);
            [unroll] for (uint a = 0; a < 12; a++) next_electric_strengths[a] -= (evolution_data.prev_electric_strength_divergences[a] - evolution_data.total_gauge_currents[a][0]) * electric_divergence_cleaning_factor * cleaning_direction;
        }

        // Evolve the magnetic gauge field given the evolution data
        void _magnetic_strengths_evolution(EvolutionCache evolution_data, out GaugeSymmetriesVectorPack next_magnetic_field_strength)
        {
            // Align the magnetic field with the gauge field
            YangMillsFormalism::field_strength_magnetic(evolution_data.gauge_field_strength_tensor, next_magnetic_field_strength);
        }

        // Evolve the gauge field given the evolution data
        void _gauge_potentials_evolution(EvolutionCache evolution_data, GaugeSymmetriesVectorPack next_electric_strengths, out GaugeSymmetriesVectorPack next_gauge_potentials)
        {
            // Initialize the slope with the electric field
            GaugeSymmetriesVectorPack temporal_slope = next_electric_strengths;

            for (uint a = 0; a < 12; a++)
            {
                if (!SimulationDataOps::is_gauge_field_active(a)) continue;
                // Add the gradient of the temporal component of the gauge potential's temporal slope
                temporal_slope[a].yzw += transpose(evolution_data.gauge_potential_jacobians[a])[0].yzw;
                // Incorporate self-interaction via commuting the field state
                for (uint i = 1; i < 4; i++) temporal_slope[a][i] += YangMillsFormalism::gauge_commutator(evolution_data.crnt_gauge_potentials, evolution_data.crnt_gauge_potentials, 0, i, a);
                // Compute the temporal gradient of the temporal component of the gauge potential
                temporal_slope[a][0] = evolution_data.gauge_potential_jacobians[a][1][1] + evolution_data.gauge_potential_jacobians[a][2][2] + evolution_data.gauge_potential_jacobians[a][3][3];
            }

            // Weighing the slope with the temporal unit (\Delta t)
            GaugeSymmetriesVectorPackMath::scl(temporal_slope, 2 * simulation_temporal_unit, temporal_slope);

            // Then , adding it to the previous state to get the next state (leap frog method).
            GaugeSymmetriesVectorPackMath::sum(evolution_data.prev_gauge_potentials, temporal_slope, next_gauge_potentials);
        }

        // Ensure the validity of the evolution result
        void _validate_result(GaugeSymmetriesVectorPack result_data, out GaugeSymmetriesVectorPack validated_result)
        {
            for (uint c = 0; c < 12; c++)
            {
                // Discard any state that's "not a number" or infinity
                const bool component_value_valid = !(any(isnan(result_data[c])) || any(isinf(result_data[c])));
                validated_result[c] = component_value_valid ? result_data[c] : float4(0,0,0,0);
            }
        }

        // Ensure the validity of the evolution result
        void _apply_norm_limit(GaugeSymmetriesVectorPack gauge_potentials, out GaugeSymmetriesVectorPack limitedState)
        {
            GaugeSymmetriesVectorPackMath::harmonically_limit_norms(gauge_potentials, simulation_gauge_norm_limit, limitedState);
        }

        // Propagate the fields to their next state
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void _propagate_to_next(EvolutionCache evolution_data)
        {
            GaugeSymmetriesVectorPack next_gauge_potentials, next_electric_strengths, next_magnetic_strengths;

            // Field Evolution
            _electric_strengths_evolution(evolution_data, next_electric_strengths);
            _magnetic_strengths_evolution(evolution_data, next_magnetic_strengths);
            _gauge_potentials_evolution(evolution_data, next_electric_strengths, next_gauge_potentials);

            // Ensure the validity of the result
            _validate_result(next_electric_strengths, next_electric_strengths);
            _validate_result(next_magnetic_strengths, next_magnetic_strengths);
            _validate_result(next_gauge_potentials, next_gauge_potentials);

            // Apply the norm limit to the gauge state
            _apply_norm_limit(next_gauge_potentials, next_gauge_potentials);

            // Finally, write the states to the buffer
            next_gauge_potentials_lattice_buffer[evolution_data.lattice_buffer_index] = next_gauge_potentials;
            next_electric_strengths_lattice_buffer[evolution_data.lattice_buffer_index] = next_electric_strengths;
            next_magnetic_strengths_lattice_buffer[evolution_data.lattice_buffer_index] = next_magnetic_strengths;
        }

        // Normal evolution function
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void gauge_evolution(float3 position)
        {
            // Load data needed for the evolution
            EvolutionCache evolution_data;
            _obtain_evolution_data(position, evolution_data);

            // Perform the evolution
            _propagate_to_next(evolution_data);
        }
    }
}

#endif
