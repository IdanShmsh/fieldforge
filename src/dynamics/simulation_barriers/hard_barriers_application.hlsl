#ifndef SIMULATION_BARRIERS_PROCESSING_HARD_BARRIERS_APPLICATION
#define SIMULATION_BARRIERS_PROCESSING_HARD_BARRIERS_APPLICATION

#include "../../core/structures/simulation_barrier_data.hlsl"
#include "../../core/ops/simulation_data_ops.hlsl"
#include "../../core/ops/fermion_field_state_ops.hlsl"
#include "../../core/ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../../core/simulation_globals.hlsl"


// TODO - this needs to be modified, concised, and polished.
namespace SimulationBarriersProcessing
{
    /// Implementation of barriers application as hard barriers - i.e. barriers that do not allow any
    /// field penetration
    /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
    namespace HardBarriersApplication
    {
        // A structure used to cache processed data associated with a barrier or necessary for its application
        struct BarrierApplicationCache
        {
            float3 position;
            float barrier_radius;
            float barrier_width;
            float3 p1, p2;
            int barrier_mask;
            bool position_within_barrier_boundary;
        };

        // This function determines whether a point is within the boundaries of a barrier
        bool _determine_point_within_barrier_boundaries(float3 position, float3 point1, float3 point2, float width, float radius)
        {
            float3 line_vec = point2 - point1;
            float  line_len = length(line_vec);
            float3 line_dir = line_vec / line_len;
            float proj = dot(position - point1, line_dir);
            float distance = length(position - (point1 + proj * line_dir));
            float axial_deviation = max(max(-proj, proj - line_len), 0);
            float normal_deviation = max(distance - width / 2, 0);
            return pow(axial_deviation, 2) + pow(normal_deviation, 2) <= pow(radius, 2);
        }

        // Constructs a structure of computed cached properties associated with a barrier
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        void _construct_barrier_application_data(float3 position, SimulationBarrierInformation barrier_data, out BarrierApplicationCache barrier_application_data)
        {
            barrier_application_data.position = position;
            barrier_application_data.barrier_width = barrier_data[1];
            barrier_application_data.barrier_radius = barrier_data[2];
            barrier_application_data.p1 = float3(barrier_data[3], barrier_data[4], barrier_data[5]);
            barrier_application_data.p2 = float3(barrier_data[6], barrier_data[7], barrier_data[8]);
            barrier_application_data.barrier_mask = barrier_data[9] & simulation_field_mask;
            barrier_application_data.position_within_barrier_boundary = _determine_point_within_barrier_boundaries(position, barrier_application_data.p1, barrier_application_data.p2, barrier_application_data.barrier_width, barrier_application_data.barrier_radius);
        }

        // This function determines whether a field is active for a given field index
        int _barrier_active_for_field(int barrier_mask, int global_field_index)
        {
            return (barrier_mask & 1 << global_field_index) != 0 ? 1 : 0;
        }

        // This function applies the barrier to all fermion fields at all accessible instances (t-1, t-0, t+1)
        // * Side Effects:
        // • Writes directly to the simulation's lattice buffers
        void _apply_barrier_to_fermion_fields(float3 position, BarrierApplicationCache barrier_application_data)
        {
            FermionFieldState empty_fermion_state;
            FermionFieldStateOps::empty(empty_fermion_state);
            for (uint fermion_field_index = 0; fermion_field_index < FERMION_FIELDS_COUNT; fermion_field_index++)
            {
                if (_barrier_active_for_field(barrier_application_data.barrier_mask, fermion_field_index) == 0) continue;
                uint fermion_lattice_buffer_index = SimulationDataOps::get_fermion_lattice_buffer_index(position, fermion_field_index);
                // In this implementation, the barrier is applied by creating an area of an absolutely 0 field.
                prev_fermions_lattice_buffer[fermion_lattice_buffer_index] =
                crnt_fermions_lattice_buffer[fermion_lattice_buffer_index] =
                next_fermions_lattice_buffer[fermion_lattice_buffer_index] =
                    empty_fermion_state;
            }
        }

        // This function applies the barrier to all gauge fields at all accessible instances (t-1, t-0, t+1)
        // * Side Effects:
        // • Writes directly to the simulation's lattice buffers
        void _apply_barrier_to_gauge_fields(float3 position, BarrierApplicationCache barrier_application_data)
        {
            GaugeSymmetriesVectorPack empty_gauge_state;
            GaugeSymmetriesVectorPackOps::empty(empty_gauge_state);
            for (uint gauge_symmetry_index = 0; gauge_symmetry_index < 12; gauge_symmetry_index++)
            {
                if (_barrier_active_for_field(barrier_application_data.barrier_mask, gauge_symmetry_index + 8) == 0) continue;
                uint gauge_lattice_buffer_index = SimulationDataOps::get_gauge_lattice_buffer_index(position);
                // In this implementation, the barrier is applied by creating an area of an absolutely 0 field.
                prev_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] =
                crnt_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] =
                next_gauge_potentials_lattice_buffer[gauge_lattice_buffer_index] =
                prev_electric_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                crnt_electric_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                next_electric_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                prev_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                crnt_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                next_magnetic_strengths_lattice_buffer[gauge_lattice_buffer_index] =
                    empty_gauge_state;
            }
        }

        // This function processes and applies a single barrier at a given position
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void process_barrier(float3 position, SimulationBarrierInformation raw_barrier_data)
        {
            // This reads the strength, which, in this implementation's context would only be a simple "on/off" flag
            if (raw_barrier_data[0] == 0) return;
            BarrierApplicationCache barrier_application_data;
            _construct_barrier_application_data(position, raw_barrier_data, barrier_application_data);
            if (!barrier_application_data.position_within_barrier_boundary) return;
            _apply_barrier_to_fermion_fields(position, barrier_application_data);
            _apply_barrier_to_gauge_fields(position, barrier_application_data);
        }

        // Process all existing barriers in the system at the moment.
        // * Side Effects:
        // • Reads directly from the simulation's lattice buffers
        // • Writes directly to the simulation's lattice buffers
        void process_barriers(float3 position)
        {
            for (int i = 0; i < BARRIERS_BUFFER_LENGTH; i++)
            {
                SimulationBarrierInformation raw_barrier_data = simulation_barriers_buffer[i];
                process_barrier(position, raw_barrier_data);
            }
        }
    }
}

#endif
