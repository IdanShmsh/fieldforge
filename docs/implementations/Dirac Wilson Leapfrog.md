# Fermion Field Evolution – Dirac Wilson Leapfrog

Recommended: [⇥ *Fermion Evolution - Pipeline Operation*](../compute_pipeline_operations/fermion_evolution.md)

## Brief

A direct implementation of Dirac's formalism for a Dirac field's dynamics and evolution in a lattice, all derived from the Dirac equation. Implementing interactions internally by accounting for the field's covariant derivatives computed using Wilson link variables.

## Theory

### Equations Of Motion

A fermion field obeys the Dirac equation:

$$
(\gamma^\mu D_\mu + im) \psi = 0 \tag{1.1.1}
$$

where $D_\mu$ is the covariant derivative, which depends on the gauge fields $A^a_\mu(x)$:

$$
D_\mu = \partial_\mu - igA_\mu^a T^a
$$

A simple algebraic development of $(1.1.1)$ leads to:

$$
D_0 \psi = \gamma^0(im - \gamma^i D_i)\psi \tag{1.2.1}
$$

An approximation of the time derivatives using finite differences can be performed, with the addition of some small time interval $\Delta t$.

### Discretization

To support an accurate discretization, the Wilson link variables would be introduced:

$$
U^n_\mu(x) = \exp(ig_a(A^a_\mu)^n(x) T^a) \tag{2.1.1}
$$

Note: The Wilson link variables are assumed to be unitary $U^n_\mu(x)^{-1} = U^n_\mu(x)^\dagger$, consistent with their role as parallel transporters in gauge space (e.g., elements of SU(3) for QCD-like interactions).

For a spinor field $\psi$ in a lattice with spacing $\Delta x$ the covariant derivative at a lattice site $x$ along an axis $\mu$ is discretized as:

$$
D_\mu \psi^n(x) \approx \frac{U^n_\mu(x)\psi(x + \Delta x \hat \mu) - \psi^n(x - \Delta x \hat \mu)}{2 \Delta x} \tag{2.1.2}
$$

To support a leapfrog structure for the evolution, a central difference form of the covariant derivative would be used along the temporal axis:

$$
D_0 \psi^n \approx \frac{U^n_0(x)\psi^{n+1}(x) - {U^{n-1}_0}^\dagger(x)\psi^{n-1}(x)}{2 \Delta t} \tag{2.1.3}
$$

From which, the following relation can be easily obtained:

$$
\psi^{n+1} = 2\Delta t \cdot U^\dagger_0(x) D_0 \psi^{n} + U^\dagger_0(x){U^{n-1}_0}^\dagger(x) \psi^{n-1} \tag{2.1.4}
$$

Substituting the expression for $D_0 \psi$ from equation $(1.2.1)$ into the leapfrog formulation yields the final update rule:

$$
\boxed{\quad
\psi^{n+1}(x) =
U^\dagger_0(x){U^{n-1}_0}^\dagger(x)\psi^{n-1}(x)
\ +\  2\Delta t \cdot \gamma^0 U^\dagger_0(x) \left(
im\psi^n(x) - \gamma^i \left[
\frac{U^n_i(x)\psi^n(x + \Delta x \ \hat i) - \psi^n(x)}{\Delta x}
\right] \right)
\quad}
$$

---

[⇥ Check out: A FieldForge compute-operation directly implementing the theory derived above](../../shaders/compute/fermion_evolution/evolve_fermion_fields-dirac_wilson_leapfrog.compute)

---

### Authors

[Idan Shemesh](https://github.com/IdanShmsh)
