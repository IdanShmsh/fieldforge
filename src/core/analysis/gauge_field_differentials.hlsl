#ifndef GAUGE_FIELDS_STATE_DIFFERENTIALS
#define GAUGE_FIELDS_STATE_DIFFERENTIALS

#include "../ops/simulation_data_ops.hlsl"
#include "../ops/gauge_symmeyries_vector_pack_ops.hlsl"
#include "../simulation_globals.hlsl"
#include "../math/gauge_symmetries_vector_pack_math.hlsl"

typedef GaugeSymmetriesVectorPack GaugeFieldsSpatialGradient[3]; // indices: [gradient-axis][gauge-symmetry][field-component]
typedef GaugeSymmetriesVectorPack GaugeFieldsSpacetimeGradient[4]; // indices: [gradient-axis][gauge-symmetry][field-component]
typedef float4x4 GaugeFieldsJacobian[12]; // indices: [gauge-symmetry][gradient-axis][field-component]
typedef float GaugeFieldsDivergence[12]; // indices: [gauge-symmetry][gradient-axis][field-component]

/// This namespace implements functions used to compute derivatives of gauge fields in the simulation.
/// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
namespace GaugeSymmetriesVectorPackDifferentials
{
    // Take the derivative of all gauge fields at a specified simulation location, along the temporal axis.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void temporal_derivative(float3 position, out GaugeSymmetriesVectorPack field_derivatives)
    {
        GaugeSymmetriesVectorPack v1 = prev_gauge_potentials_lattice_buffer[SimulationDataOps::get_gauge_lattice_buffer_index(position)];
        GaugeSymmetriesVectorPack v2 = crnt_gauge_potentials_lattice_buffer[SimulationDataOps::get_gauge_lattice_buffer_index(position)];
        GaugeSymmetriesVectorPackMath::sub(v2, v1, field_derivatives);
        GaugeSymmetriesVectorPackMath::scl(field_derivatives, 1 / simulation_temporal_unit, field_derivatives);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along a specified spatial axis,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeSymmetriesVectorPack field_derivatives)
    {
        GaugeSymmetriesVectorPackOps::empty(field_derivatives);
        if (axis > SPATIAL_DIMENSIONALITY - 1) return;
        float3 offset = float3(0, 0, 0);
        offset[axis] = 1;
        uint idx1 = SimulationDataOps::get_gauge_lattice_buffer_index(position - offset);
        uint idx2 = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset);
        GaugeSymmetriesVectorPack v1 = lattice_buffer[idx1];
        GaugeSymmetriesVectorPack v2 = lattice_buffer[idx2];
        GaugeSymmetriesVectorPack s;
        GaugeSymmetriesVectorPackMath::sub(v2, v1, s);
        GaugeSymmetriesVectorPackMath::scl(s, 0.5 / simulation_spatial_unit, field_derivatives);
    }

    // Take the second derivative of all gauge fields at a specified simulation location, along a pair of specified spatial axes,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_second_derivative(uint2 axes, float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeSymmetriesVectorPack field_second_derivatives)
    {
        GaugeSymmetriesVectorPackOps::empty(field_second_derivatives);
        float3 offset1 = float3(0, 0, 0);
        float3 offset2 = float3(0, 0, 0);
        offset1[axes.x] = 1;
        offset2[axes.y] = 1;
        uint idx1 = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset1 + offset2);
        uint idx2 = SimulationDataOps::get_gauge_lattice_buffer_index(position + offset1 - offset2);
        uint idx3 = SimulationDataOps::get_gauge_lattice_buffer_index(position - offset1 + offset2);
        uint idx4 = SimulationDataOps::get_gauge_lattice_buffer_index(position - offset1 - offset2);
        GaugeSymmetriesVectorPack v1 = lattice_buffer[idx1];
        GaugeSymmetriesVectorPack v2 = lattice_buffer[idx2];
        GaugeSymmetriesVectorPack v3 = lattice_buffer[idx3];
        GaugeSymmetriesVectorPack v4 = lattice_buffer[idx4];
        GaugeSymmetriesVectorPack s;
        GaugeSymmetriesVectorPackMath::sub(v2, v1, s);
        GaugeSymmetriesVectorPackMath::sub(s, v3, s);
        GaugeSymmetriesVectorPackMath::sum(s, v4, s);
        GaugeSymmetriesVectorPackMath::scl(s, 0.25 / simulation_spatial_unit, field_second_derivatives);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along a specified spatial axis,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_derivative(uint axis, float3 position, out GaugeSymmetriesVectorPack derivative)
    {
        spatial_derivative(axis, position, crnt_gauge_potentials_lattice_buffer, derivative);
    }

    // Take the second derivative of all gauge fields at a specified simulation location, along a specified spacetime axis,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_derivative(uint axis, float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeSymmetriesVectorPack field_derivatives)
    {
        if (axis == 0) temporal_derivative(position, field_derivatives);
        else spatial_derivative(axis - 1, position, lattice_buffer, field_derivatives);
    }

    // Take the second derivative of all gauge fields at a specified simulation location, along a specified spacetime axis,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_derivative(uint axis, float3 position, out GaugeSymmetriesVectorPack derivative)
    {
        if (axis == 0) temporal_derivative(position, derivative);
        else spatial_derivative(axis - 1, position, derivative);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along all spacetime axes,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_gradient(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeFieldsSpacetimeGradient field_gradients)
    {
        temporal_derivative(position, field_gradients[0]);
        spatial_derivative(0, position, lattice_buffer, field_gradients[1]);
        spatial_derivative(1, position, lattice_buffer, field_gradients[2]);
        spatial_derivative(2, position, lattice_buffer, field_gradients[3]);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along all spacetime axes,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spacetime_gradient(float3 position, out GaugeFieldsSpacetimeGradient field_gradients)
    {
        temporal_derivative(position, field_gradients[0]);
        spatial_derivative(0, position, field_gradients[1]);
        spatial_derivative(1, position, field_gradients[2]);
        spatial_derivative(2, position, field_gradients[3]);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along all spatial axes,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_gradient(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeFieldsSpatialGradient field_gradients)
    {
        spatial_derivative(0, position, lattice_buffer, field_gradients[0]);
        spatial_derivative(1, position, lattice_buffer, field_gradients[1]);
        spatial_derivative(2, position, lattice_buffer, field_gradients[2]);
    }

    // Take the derivative of all gauge fields at a specified simulation location, along all spatial axes,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void spatial_gradient(float3 position, out GaugeFieldsSpatialGradient gradient)
    {
        spatial_derivative(0, position, gradient[0]);
        spatial_derivative(1, position, gradient[1]);
        spatial_derivative(2, position, gradient[2]);
    }

    // Reconstruct a gauge field spacetime gradient into jacobian matrices
    void jacobian(GaugeFieldsSpacetimeGradient gradient, out GaugeFieldsJacobian result)
    {
        for (uint a = 0; a < 12; a++) for (uint i = 0; i < 4; i++) result[a][i] = gradient[i][a];
    }

    // Take the Jacobians of all gauge fields at a specified simulation location, along all spacetime axes,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void jacobian(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeFieldsJacobian field_jacobians)
    {
        GaugeFieldsSpacetimeGradient gradient;
        spacetime_gradient(position, lattice_buffer, gradient);
        jacobian(gradient, field_jacobians);
    }

    // Take the Jacobians of all gauge fields at a specified simulation location, along all spacetime axes,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void jacobian(float3 position, out GaugeFieldsJacobian field_jacobians)
    {
        jacobian(position, crnt_gauge_potentials_lattice_buffer, field_jacobians);
    }

    // Take the divergence of all gauge fields at a specified simulation location, in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void divergence(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeFieldsDivergence field_divergences)
    {
        GaugeFieldsSpatialGradient gradient;
        spatial_gradient(position, lattice_buffer, gradient);
        for (uint a = 0; a < 12; a++) field_divergences[a] = gradient[0][a][1] + gradient[1][a][2] + gradient[2][a][3]; // unroll
    }

    // Take the divergence of all gauge fields at a specified simulation location, in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void divergence(float3 position, out GaugeFieldsDivergence field_divergences)
    {
        divergence(position, crnt_gauge_potentials_lattice_buffer, field_divergences);
    }

    // Take the divergence of all gauge fields, given a spacetime gradient. // TODO: overload for SpatialGradient
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void divergence(GaugeFieldsSpacetimeGradient gradient, out GaugeFieldsDivergence field_divergences)
    {
        for (uint a = 0; a < 12; a++) field_divergences[a] = gradient[1][a][1] + gradient[2][a][2] + gradient[3][a][3]; // unroll
    }

    // Take the curl of all gauge fields at a specified simulation location, in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void curl(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeSymmetriesVectorPack field_curls)
    {
        GaugeFieldsSpatialGradient gradient;
        spatial_gradient(position, lattice_buffer, gradient);
        for (uint a = 0; a < 12; a++) field_curls[a] = float4(
                0,
                gradient[1][a][3] - gradient[2][a][2],
                gradient[2][a][1] - gradient[0][a][3],
                gradient[0][a][2] - gradient[1][a][1]
            );
    }

    // Take the curl of all gauge fields at a specified simulation location, in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void curl(float3 position, out GaugeSymmetriesVectorPack field_curls)
    {
        curl(position, crnt_gauge_potentials_lattice_buffer, field_curls);
    }

    // Take the curl of all gauge fields, given a spacetime gradient. // TODO: overload for SpatialGradient
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void curl(GaugeFieldsSpacetimeGradient gradient, out GaugeSymmetriesVectorPack field_curls)
    {
        for (uint a = 0; a < 12; a++) field_curls[a] = float4(
                0,
                gradient[2][a][3] - gradient[3][a][2],
                gradient[3][a][1] - gradient[1][a][3],
                gradient[1][a][2] - gradient[2][a][1]
            );
    }


    // Take the gradient of the divergences of all gauge fields at a specified simulation location,
    // in a specified gauge lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void divergenceGradient(float3 position, GaugeLatticeBuffer lattice_buffer, out GaugeSymmetriesVectorPack field_divergence_gradients)
    {
        GaugeSymmetriesVectorPackOps::empty(field_divergence_gradients);
        for (uint i = 0; i < 3; i++) for (uint j = 0; j < 3; j++)
        {
            GaugeSymmetriesVectorPack temp;
            spatial_second_derivative(float2(i,j), position, lattice_buffer, temp);
            for (uint a = 0; a < 12; a++) field_divergence_gradients[a] += temp[a][j];
        }
    }

    // Take the gradient of the divergences of all gauge fields at a specified simulation location,
    // in the current gauge potentials lattice buffer.
    // * Side Effects:
    // • Reads directly from the simulation's lattice buffers.
    void divergenceGradient(float3 position, out GaugeSymmetriesVectorPack field_divergence_gradients)
    {
        divergenceGradient(position, crnt_gauge_potentials_lattice_buffer, field_divergence_gradients);
    }
}

#endif
