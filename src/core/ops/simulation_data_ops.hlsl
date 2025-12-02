#ifndef SIMULATION_DATA_OPS
#define SIMULATION_DATA_OPS

#include "../simulation_globals.hlsl"

/// This namespace implements functions used to operate on global data/structures in the simulation
namespace SimulationDataOps
{
    // Check if a position is within the simulation space
    bool is_within(half3 position)
    {
        return all(position >= half3(0, 0, 0) && position <= half3(simulation_width, simulation_height, simulation_depth));
    }

    // Check if a position is at the boundary of the simulation
    bool is_boundary(half3 position)
    {
        return any(position <= half3(0, 0, 0) || position >= half3(simulation_width - 1, simulation_height - 1, simulation_depth - 1));
    }

    // Check if a position is at the boundary of the simulation along the x-axis
    bool is_boundary_x(half3 position)
    {
        return any(position.x <= 0 || position.x >= simulation_width - 1);
    }

    // Check if a position is at the boundary of the simulation along the y-axis
    bool is_boundary_y(half3 position)
    {
        return any(position.y <= 0 || position.y >= simulation_height - 1);
    }

    // Check if a position is at the boundary of the simulation along the z-axis
    bool is_boundary_z(half3 position)
    {
        return any(position.z <= 0 || position.z >= simulation_depth - 1);
    }

    // Clamp a position to the simulation space
    half3 clamp_position(half3 position)
    {
        const half3 simulation_bounds = half3(simulation_width, simulation_height, simulation_depth);
        return position - simulation_bounds * floor(position / simulation_bounds);
    }

    // Get the lattice buffer index of a fermion field's state at a given position
    uint get_fermion_lattice_buffer_index(half3 position, uint field_index)
    {
        position = clamp_position(position);
        return ((field_index * simulation_depth + (uint)position[2]) * simulation_height + (uint)position[1]) * simulation_width + (uint)position[0];
    }

    // Get the lattice buffer index of a gauge fields state at a given position
    uint get_gauge_lattice_buffer_index(half3 position)
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
    half3 obtain_fermion_coupling_constants_tuple(uint fermion_field_index)
    {
        FermionFieldProperties field_properties = fermion_field_properties[fermion_field_index];
        return half3(
            field_properties.u1_interaction_coupling,
            field_properties.su2_interaction_coupling,
            field_properties.su3_interaction_coupling
        );
    }

    void copy_buffer_information_at_position(half3 position, FermionLatticeBuffer from_buffer, FermionLatticeBuffer to_buffer)
    {
        for (uint field_index = 0 ; field_index < FERMION_FIELDS_COUNT; field_index++)
        {
            uint index = get_fermion_lattice_buffer_index(position, field_index);
            to_buffer[index] = from_buffer[index];
        }
    }

    void copy_buffer_information_at_position(half3 position, GaugeLatticeBuffer from_buffer, GaugeLatticeBuffer to_buffer)
    {
        uint index = get_gauge_lattice_buffer_index(position);
        to_buffer[index] = from_buffer[index];
    }
}

#endif
