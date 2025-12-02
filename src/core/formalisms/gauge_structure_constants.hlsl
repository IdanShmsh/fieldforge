#ifndef GAUGE_STRUCTURE_CONSTANTS
#define GAUGE_STRUCTURE_CONSTANTS

/// Encodes the gauge structure tensor f⁽ᵃᵇᶜ⁾ in a data/runtime efficient format.
/// Instead of directly acting on a shallow representation of f⁽ᵃᵇᶜ⁾, which contains many 0s making computations
/// like f⁽ᵃᵇᶜ⁾ Aᵇμ Aᶜν being mostly redundant memory accesses and unnecessary computations, we rely on
/// apparent characteristics of f⁽ᵃᵇᶜ⁾ to encode it in a more efficient way.
/// For a given index 'a', there exist, at most, two pairs of indices 'b', 'c' for which f⁽ᵃᵇᶜ⁾ ≠ 0.
/// The data structure bellow consists of a list of 12 pairs of half3 literals, each associated with one of the 12 possible symmetry
/// indexes 'a' may represent. For a given 'a' index, each half3 in the pair contains a non-0 value of f⁽ᵃᵇᶜ⁾ given
/// for a pair 'b', 'c', together with the actual values of 'b', 'c' corresponding to that component.
/// Shortly: gauge_structure_constants[a] = { (f⁽ᵃᵇᶜ⁾, b, c), (f⁽ᵃᵇᶜ⁾, b, c) }.

static const half3 gauge_structure_constants[12][2] = {
    {
        half3(0, 0, 0),
        half3(0, 0, 0),
    },
    {
        half3(1, 3, 2),
        half3(0, 0, 0)
    },
    {
        half3(-1, 3, 1),
        half3(0, 0, 0),
    },
    {
        half3(1, 2, 1),
        half3(0, 0, 0),
    },
    {
        half3(1, 6, 5),
        half3(0, 0, 0),
    },
    {
        half3(0.5, 11, 8),
        half3(-0.5, 10, 9),
    },
    {
        half3(0.5, 10, 8),
        half3(0.5, 11, 9),
    },
    {
        half3(0.5, 9, 8),
        half3(-0.5, 11, 10),
    },
    {
        half3(0.866025, 11, 9),
        half3(0, 0, 0),
    },
    {
        half3(0, 0, 0),
        half3(0, 0, 0),
    },
    {
        half3(-0.866025, 11, 11),
        half3(0, 0, 0),
    },
    {
        half3(0, 0, 0),
        half3(0, 0, 0),
    }
};

#endif
