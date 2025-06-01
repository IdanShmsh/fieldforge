# Pokes Handling

This category of compute shaders operates in FieldForge's compute-pipeline to expose and perform the application of 'pokes' (a user provided local disturbance of the fields) to fields in the simulation allowing external control over field configurations provided in a formal way.

---

### Implementation Guidelines

#### Always Should

- Process all items in the pokes buffer.
- **Sum** states associated with each mode to the fields in the 'current' buffers (`crnt_...`).

#### Sometimes Could

- **Sum** states associated with each mode to the fields in the 'previous' buffers (`prev_...`).

#### Never Would

- Write to the 'next' buffers (`next_...`).
- **Overwrite** an existing state in any buffer.

---

### Implementations

---

#### [User Centered Interactive](../..//shaders/compute/pokes_handling/handle_pokes-user_centered_interactive.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

An implementation that handles simulation pokes in a "User Centered Approach". Applying a poke with all configured properties, with a spacial profile that aims to mimic *'a ripple in a pond ≈≈'*.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
