# Guardrails

Guardrails are the essence of FieldForge's informal approaches, stepping away from physical accuracy and scientific insight and pulling it closer toward human requirements and numerical practicallity. Guardrails are used to apply unphysical dynamics to the fields in the simulation, mostly in situations where pure physics alone would let the ball rolling into the gutter. High-oscilatory configurations can be avoided by applying *field denoising/bluring*, infinite-time evolutions can be made finite in time by breaking energy conservation via *energy dissipation* etc.

---

### Implementation Guidelines

Guardrails are allowed to do anything plausible.

---

### Implementations

---

#### [Activity Dependent Blurring](../../shaders/compute/guardrails/guardrails-activity_dependent_bluring.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

This guardrail technique blurs the fields in the simulation by applying a local gaussian kernel to them. The blur radius applied to a region is directly proportional to the local energy density in it - blurring more aggressively in active regions of the simulation.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*

---

#### [Activity Dependent Energy Dissipation](../../shaders/compute/guardrails/guardrails-activity_dependent_energy_dissipation.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

This guardrail technique dissipates energy from the simulation only by applying a positive-definite scale factor to the fields within it. The scale factor applied to a region is directly proportional to the local energy density in it - dissipating energy more aggressively in active regions of the simulation.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*

---

#### [Passive Bilateral Field Denoising](../../shaders/compute/guardrails/guardrails-passive_bilateral_field_denoising.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

This guardrail technique applies a bilateral denoising algorithm uniformly to every local region, smoothing the configuration of all fields in the simulation.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*

---

#### [Passive Field Blurring](../../shaders/compute/guardrails/guardrails-passive_field_bluring.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

This guardrail technique blurs the fields in the simulation by applying a local gaussian kernel to them uniformly in every local region, smoothing the configuration of all fields in the simulation.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*

---

#### [Passive Scaling Energy Dissipation](../../shaders/compute/guardrails/guardrails-passive_scaling_energy_dissipation.compute)

By: [Idan Shemesh](https://github.com/IdanShmsh)

##### Description

This guardrail technique dissipates energy from the simulation only by applying a positive-definite scale factor to the fields within it uniformly in every local region.

##### Optimizations

No trade-off inducing optimizations.

##### Theoretical Documentation

*Nothing So Far*
