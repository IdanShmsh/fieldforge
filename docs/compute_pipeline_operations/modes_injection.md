# Modes Injection

This category of compute shaders operates in FieldForge's compute-pipeline to expose and perform the application of field modes to fields in the simulation allowing external control over field configurations provided in a formal way.

---

### Implementation Guidelines

#### Always Should

- Process all items in the modes buffers.
- **Sum** states associated with each mode to the fields in the 'current' buffers (`crnt_...`).

#### Sometimes Could

- **Sum** states associated with each mode to the fields in the 'previous' buffers (`prev_...`).

#### Never Would

- Write to the 'next' buffers (`next_...`).
- **Overwrite** an existing state in any buffer.

---

### Implementations

---

#### [Direct Modes Injection](../../shaders/compute/modes_injection/inject_modes-direct_modes_injection.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

Directly applying configured modes to the currnt and previous buffers supporting proceeding evolutions.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far* - todo.
