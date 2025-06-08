#ifndef SIMULATION_DATA_OPS
#define SIMULATION_DATA_OPS

#include "../simulation_globals.hlsl"

/// This namespace implements functions used to operate on global data/structures in the simulation
namespace SimulationDataOps
{
    // Check if a position is within the simulation space
    bool is_within(float3 position)
    {
        return all(position >= float3(0, 0, 0) && position <= float3(simulation_width, simulation_height, simulation_depth));
    }

    // Check if a position is at the boundary of the simulation
    bool is_boundary(float3 position)
    {
        return any(position <= float3(0, 0, 0) || position >= float3(simulation_width - 1, simulation_height - 1, simulation_depth - 1));
    }

    // Check if a position is at the boundary of the simulation along the x-axis
    bool is_boundary_x(float3 position)
    {
        return any(position.x <= 0 || position.x >= simulation_width - 1);
    }

    // Check if a position is at the boundary of the simulation along the y-axis
    bool is_boundary_y(float3 position)
    {
        return any(position.y <= 0 || position.y >= simulation_height - 1);
    }

    // Check if a position is at the boundary of the simulation along the z-axis
    bool is_boundary_z(float3 position)
    {
        return any(position.z <= 0 || position.z >= simulation_depth - 1);
    }

    // Clamp a position to the simulation space
    float3 clamp_position(float3 position)
    {
        const float3 simulation_bounds = float3(simulation_width, simulation_height, simulation_depth);
        return position - simulation_bounds * floor(position / simulation_bounds);
    }

    // Get the lattice buffer index of a fermion field's state at a given position
    uint get_fermion_lattice_buffer_index(float3 position, uint field_index)
    {
        position = clamp_position(position);
        return ((field_index * simulation_depth + (uint)position[2]) * simulation_height + (uint)position[1]) * simulation_width + (uint)position[0];
    }

    // Get the lattice buffer index of a gauge fields state at a given position
    uint get_gauge_lattice_buffer_index(float3 position)
    {
        position = clamp_position(position);
        return (uint(position[2]) * simulation_height + (uint)position[1]) * simulation_width + (uint)position[0];
    }

    // Check if a fermion field is active in the simulation
    bool is_simulation_field_active(uint field_index)
    {
        return (simulation_field_mask & 1 << field_index) != 0;
    }

    // Check if a fermion field is active in the simulation
    bool is_fermion_field_active(uint field_index)
    {
        return is_simulation_field_active(field_index);
    }

    // Check if a gauge field is active in the simulation
    bool is_gauge_symmetry_active(uint field_index)
    {
        return is_simulation_field_active(field_index + FERMION_FIELDS_COUNT);
    }

    // Obtain a tuple containing a fermion field's 3 coupling constants given that field's index
    float3 obtain_fermion_coupling_constants_tuple(uint fermion_field_index)
    {
        FermionFieldProperties field_properties = fermion_field_properties[fermion_field_index];
        return float3(
            field_properties.u1_interaction_coupling,
            field_properties.su2_interaction_coupling,
            field_properties.su3_interaction_coupling
        );
    }

    void copy_buffer_information_at_position(float3 position, FermionLatticeBuffer from_buffer, FermionLatticeBuffer to_buffer)
    {
        for (uint field_index = 0 ; field_index < FERMION_FIELDS_COUNT; field_index++)
        {
            uint index = get_fermion_lattice_buffer_index(position, field_index);
            to_buffer[index] = from_buffer[index];
        }
    }

    void copy_buffer_information_at_position(float3 position, GaugeLatticeBuffer from_buffer, GaugeLatticeBuffer to_buffer)
    {
        uint index = get_gauge_lattice_buffer_index(position);
        to_buffer[index] = from_buffer[index];
    }
}

#endif
