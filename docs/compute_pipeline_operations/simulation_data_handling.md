# Simulation Data Handling

This category of compute shaders operates in FieldForge's compute-pipeline to perform all global data handling operations, technically required in the simulation.

### Implementation Guidelines

Generally - these processes should not alter the simulation state via any local logic, they should only operate on the simulation data globally and uniformly.

---

### Implementations

---

#### [Step Simulation](../../shaders/compute/simulation_stepping/step_simulation.compute)

##### Description

A simple implementation consisting of all minimally required operations for a simulation step - looping buffers (`crnt_...` --> `prev_...`, `next_...` --> `crnt_...`, `<reset>` --> `next_...` ... ), incrementing global counters (`global_intrinsics[GI_FRAME_COUNT] += 1;` ... ), resetting components, etc...

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
