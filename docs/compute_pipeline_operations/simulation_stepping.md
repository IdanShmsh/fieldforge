# Simulation Stepping

This category of compute shaders operates in FieldForge's compute-pipeline to perform all global operations, technically required between every simualtion step (frame - normally).

### Implementation Guidelines

#### Always Should

- Loop field buffers - `crnt_...` --> `prev_...`, `next_...` --> `crnt_...`, `<reset>` --> `next_...` ...
- Update global intrinsics buffer - `global_intrinsics[GI_FRAME_COUNT] += 1;` ...

#### Sometimes Could

#### Never Would

---

### Implementations

---

#### [Step Simulation](../../shaders/compute/simulation_stepping/step_simulation.compute)

##### Description

A simple implementation consisting of all minimally required operations for a simulation step - looping buffers, incrementing global counters, reseting components etc...

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
