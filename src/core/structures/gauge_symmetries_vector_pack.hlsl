#ifndef GAUGE_SYMMETRIES_VECTOR_PACK
#define GAUGE_SYMMETRIES_VECTOR_PACK

/// This data structure stores a 4-vector value for each of the 12 gauge symmetries
typedef float4 GaugeSymmetriesVectorPack[12]; // [float4 * (1 (U1) + 3 (SU2) + 8 (SU3) = 12 symmetries)]

/// An alias for specifying the type associated with a buffer that stores gauge symmetries vector packs (a gauge lattice).
typedef RWStructuredBuffer<GaugeSymmetriesVectorPack> GaugeLatticeBuffer;

#endif
