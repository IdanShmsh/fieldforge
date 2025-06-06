# Rendering Preparation

This category of compute shaders operates in FieldForge's compute-pipeline to perform all pre-rendering compute passes that prepare a set of field buffers properly ready to be rendered. Unlike rendering shaders which act in screen space, these operations act in simulation space on the fields themselves performing a modular preparation of the fields themselves for a rendering.

### Implementation Guidelines

#### Always Should

- Load and or manipulate the data in dedicated field rendering buffers - `crnt_...` --> `rend_...`

#### Sometimes Could

#### Never Would

- Load and or manipulate data in any other field buffer.

---

### Implementations

---

#### [Load Current State](../../shaders/compute/rendering_preparation/prepare_rendering-load_crnt_state.compute)

##### Description

This operation loads the current state of the entire simulation into all rendering buffers.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
