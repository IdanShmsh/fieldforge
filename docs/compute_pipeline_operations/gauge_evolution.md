# Gauge Evolution

### Implementation Guidelines

#### Always Should

- Write to **all** values corresponding to **active gauge fields** in the buffer `next_gauge_potentials_lattice_buffer`.

#### Sometimes Could

- Implement internal interaction logic.
- Write to **all** values corresponding to **active gauge fields** in the buffers `next_electric_strengths_lattice_buffer / next_magnetic_strengths_lattice_buffer`.

#### Never Would

- Write to the buffers: `crnt/prev_gauge_potentials_lattice_buffer , crnt/prev_electric_strengths_lattice_buffer , crnt/prev_magnetic_strengths_lattice_buffer`
- Handle **inactive gauge symmetries**.

---

### Implementations

---

#### [Yang-Mills Leapfrog](../../shaders/compute/gauge_evolution/evolve_gauge_fields-yang_mills_leapfrog.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

A direct implementation of a gauge field's dynamics using a leapfrog temporal update, utilizing explicit persisting "electric" and "magnetic" gauge strength fields, with interactions internally implemented using standard Yang-Mills formalism. Includes no forced retrospective corrections. Uses the Lorentz Gauge Condition for a Gauge-fixing technique.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

[⇥ Gauge Field Evolution - Yang-Mills Leapfrog](../implementations/Yang%20Mills%20Leapfrog.md)
