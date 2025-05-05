### Implementation Guidelines

#### Always Should

- Write to **all** values corresponding to **active gauge fields** in the buffer "next_gauge_potentials_lattice_buffer".
- Calculate and accumulate the energy of all **active gauge fields** at all locations in the current lattice.

#### Sometimes Could

- Implement internal interaction logic.
- Write to **all** values corresponding to **active gauge fields** in the buffers "next_electric_strengths_lattice_buffer, next_magnetic_strengths_lattice_buffer" (electric/magnetic field lattices associated with the gauge fields).

#### Never Would

- Write to the "crnt/prev_fermions_lattice_buffer".
- Handle **inactive fermion fields**.

---

### Implementations

---

#### PlnLfYMInt

##### Description

Plain implementation of a gauge field's dynamics using a leapfrog temporal update, utilizing explicit, persisting "electric" and "magnetic" gauge strength fields, with interactions internally implemented using standard Yang-Mills formalism. Includes no forced retrospective corrections. Uses the Lorentz Gauge Condition for a Gauge-fixing technique.

##### Optimizations

No trade-off inducing optimizations.

##### Required Global Buffers

TODO

---
