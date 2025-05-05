### Implementation Guidelines

#### Always Should

- Write to **all** values corresponding to **active fermion fields** in the buffer "next_fermions_lattice_buffer".
- Calculate and accumulate the energy of all **active fermion fields** at all locations in the current lattice.

#### Sometimes Could

- Implement internal interaction logic.

#### Never Would

- Write to the "crnt/prev_fermions_lattice_buffer".
- Handle **inactive fermion fields**.

---

### Implementations

---

#### Dirac Wilson Leapfrog

##### Description

Plain implementation of a Dirac field's dynamics using a leapfrog temporal update, with interactions internally implemented using Wilson lines.

##### Optimizations

No trade-off inducing optimizations.

##### Required Global Buffers

TODO

---
