# Barriers Handling

This category of compute shaders operates in FieldForge's compute-pipeline to expose and perform the application of 'barriers' (a constant dampening/shutting-off of fields) to fields in the simulation allowing external control over the *'environment'* in which the fields live.

---

### Implementation Guidelines

#### Always Should

- Process all items in the barriers buffer.
- Apply the barriers to states in the 'current' buffers (`crnt_...`).

#### Sometimes Could

- **Apply the barriers to states in the 'previous' buffers (`prev_...`).

#### Never Would

- Write to the 'next' buffers (`next_...`).
- **Overwrite** an existing state in any buffer.

---

### Implementations

---

#### [Hard Barriers Application](../../shaders/compute/pokes_handling/handle_barriers-hard_barriers_application.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

An implementation that handles simulation barriers by applying them as "hard barriers" - regions where the configured fields are shut-off entirely.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
