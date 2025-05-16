# Fermion Evolution

This category of compute shaders operates in FieldForge's compute-pipeline to perform evolution updates on fermion fields.Multiple interchangeable implementations may exist, each encoding a different evolution strategy or interaction model, but all must adhere to the guidelines below to ensure compatibility with the global simulation architecture.

---

### Implementation Guidelines

#### Always Should

- Write to **all** values corresponding to **active fermion fields** in the buffer `next_fermions_lattice_buffer`.

#### Sometimes Could

- Implement internal interaction logic.

#### Never Would

- Write to the buffers `crnt/prev_fermions_lattice_buffer`.
- Handle **inactive fermion fields**.

---

## Implementations

---

#### [Dirac Wilson Leapfrog](../../shaders/compute/fermion_evolution/evolve_fermion_fields-dirac_wilson_leapfrog.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

Plain implementation of a Dirac field's dynamics using a leapfrog temporal update, with interactions internally implemented using Wilson lines.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

[⇥ Fermion Field Evolution - Dirac-Wilson Leapfrog](../implementations/Dirac%20Wilson%20Leapfrog.md)

---
