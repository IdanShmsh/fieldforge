# Gauge Field Evolution - Yang-Mills Leapfrog

Recommended: [⇥ *Gauge Evolution*](../compute_pipeline_operations/gauge_evolution.md)

## Brief

A direct implementation of Yang-Mills gauge field dynamics, derived from the field strength tensor and Yang-Mills equations of motion. Interactions with matter fields and non-Abelian self-interactions are implemented explicitly using source currents and structure constants. Electric and magnetic fields are evolved using a staggered leapfrog scheme.

Gauge-Fixing: *Lorentz Gauge Condition*.

## Theory

### Equations Of Motion

One would start from the Yang-Mills equations of motion and progressively derive discretized evolution laws for the gauge potential and electric field, consistent with leapfrog temporal integration.

For a gauge field $A_\mu^a$, the field strength tensor is defined as:

$$
F_{\mu\nu}^a = \partial_\mu A_\nu^a - \partial_\nu A_\mu^a - f^{abc} A_\mu^b A_\nu^c \tag{1.1.1}
$$

Here:

- $g$ is the self-interaction coupling constant.
- $f^{abc}$ are the structure constants of the Lie algebra associated with the gauge symmetry of the field.

The equations of motion for $F_{\mu\nu}^a$ are:

$$
D^\nu F_{\nu\mu}^a = J_\mu^a \tag{1.1.2}
$$

where:

- $D_\nu F_{\nu\mu}^a = \partial_\nu F_{\nu\mu}^a + f^{abc} A_\nu^b F_{\nu\mu}^c$ - is the gauge-covariant derivative
- $J_\mu^a$ - is the source current

The relation $(1.1.2)$ takes the expanded form explicitly written in terms of the gauge potential $A^a_\mu$:

$$
\partial_\nu (\partial_\nu A_\mu^a - \partial_\mu A_\nu^a - f^{abc} A_\nu^b A_\mu^c) + f^{abc} A_\nu^b (\partial_\nu A_\mu^a - \partial_\mu A_\nu^a - f^{cde} A_\nu^d A_\mu^e)-J_\mu^a = 0 \tag{1.1.3}
$$

This represents a valid equation of motion for the gauge potential $A_\mu$. However, this relation is both highly complicated and computationally expensive.

*A significant simplification (though, accuracy maintaining) approach is needed.*

### Gauge Potential Evolution

The "electric field" $E^a_i$ and the "magnetic field" $B^a_i$ are defined as follows:

$$
E^a_i = F^a_{0i} \quad B^a_i = -\frac12 \epsilon_{ijk} F^a_{jk} \tag{1.2.1}
$$

Making the electric field, by the definition of the fields strength tensor, explicitly:

$$
E^a_i = \partial_0 A^a_i - \partial_i A^a_0 - f^{abc}A^b_0 A^c_i \tag{1.2.2}
$$

leading to the relation:

$$
\partial_0 A^a_i = E^a_i + \partial_i A^a_0 + f^{abc}A^b_0 A^c_i \tag{1.2.3}
$$

which can be used to propagate the gauge field $A^a_\mu$ to the next temporal instance.

### Electric Field Evolution

The "electric field" $E^a_\mu$ would itself need to be evolved separately before used. The evolution relation of the field strength tensor would be used (eq. $1.1.2$):

$$
D^\nu F^a_{\nu\mu}=J^a_\mu \tag{1.3.1}
$$

Which, can be trivially rewritten:

$$
\partial^0 E^a_\mu -\partial^i F^a_{i\mu} + f^{abc} A^b_0 F^c_{\nu\mu} = J^a_\mu \tag{1.3.2}
$$

Leading to:

$$
\partial_0 E^a_\mu = J^a_\mu + \partial^i F^a_{i\mu} - \Sigma_\nu g f^{abc} A^b_0 F^c_{\nu\mu} \tag{1.3.3}
$$

The term $\partial^i F^a_{i\mu}$ represents the following:

$$
\partial^i F^a_{i\mu} = \begin{cases}\vec \nabla \cdot E^a && \mu = 0 \\ (\vec \nabla \times B^a)_\mu&& \mu\in \{1,2,3\} \end{cases} \tag{1.3.4}
$$

Which results in the following relation for the temporal derivative of the electric field:

$$
\partial_0 E^a_i = J^a_i + (\vec \nabla\times B^a)_i - \Sigma_\nu g f^{abc} A^b_0 F^c_{\nu i}\tag{1.3.5}
$$

This is Ampere's Law in a Yang-Mills theory.

The $\mu = 0$ case provides the following relation as well:

$$
\partial_0 E^a_0 = J^a_0 + \vec\nabla\cdot E^a - \Sigma_\nu g f^{abc} A^b_0 F^c_{\nu\mu} \tag{1.3.6}
$$

Which, by $E_0 = 0$ leads to:

$$
\vec\nabla\cdot E^a = -J^a_0 + \Sigma_\nu g f^{abc} A^b_0 F^c_{\nu\mu} \tag{1.3.7}
$$

This is Gauss's Law in a Yang-Mills theory.

### Gauge Potential Temporal Component Handling

Equation $1.2.3$ only handle's the spatial components of the gauge potential $A^a$ and leaves an ambiguity for the temporal component $A^a_0$.

For that the *Lorentz Gauge Fixing* technique is chosen:

$$
\partial^\mu A^a_\mu = 0 \tag{1.4.3}
$$

Leading to the relation:

$$
\partial^0 A^a_0 = \partial^i A^a_i \tag{1.4.4}
$$

Which allows for the determination of the temporal slope of the temporal component of $A^a$ to be solved for, based on the spatial divergence of the field $A^a$.

## Discretization

Let the gauge field $A^a$ at time $t^n$ be $(A^a)^n$. The first order temporal derivative is discretized as:

$$
\partial_0 A_\mu^a=\frac{(A_\mu^a)^{n+1} - (A_\mu^a)^{n-1}}{2\Delta t} \tag{2.1.1}
$$

This relation, would be used to evolve the gauge field to the next temporal instance $(A^a)^{n+1}$ via the trivially obtained relation:

$$
(A_\mu^a)^{n+1} = (A_\mu^a)^{n-1} + 2\Delta t (\partial_0 A_\mu^a) \tag{2.1.2}
$$

Likewise, let the electric field $E^a$ at time $t^n$ be $(E^a)^n$. The first order temporal derivative is discretized as:

$$
\partial_0 E_\mu^a = \frac{(E_\mu^a)^{n+1} - (E_\mu^a)^{n-1}}{2 \Delta t} \tag{2.1.3}
$$

Allowing for the electric field's value to be worked out in the next temporal instance $(E^a)^{n+1}$ via the relation:

$$
(E_\mu^a)^{n+1} = (E_\mu^a)^{n-1} + 2 \Delta t (\partial_0 E_\mu^a) \tag{2.1.4}
$$

## Temporal Alignment

An initially hidden issue is found within this theoretical development, involving the dependency of the three fields $A^a_\mu$, $E^a_i$, and $B^a_i$ on each other, and their temporal alignment.

As laid out in [this writing](../Structure%20And%20Theory.md), the simulation persists 3-independent lattice buffers encoding the configuration of each field at 3 consecutive temporal instances: previous $(n-1)$, current $(n)$, next $(n-1)$.

To ensure stability and correctness under leapfrog integration, one must take care that each field is evolved using quantities from appropriate temporal layers.

In particular:

- The gauge potential $A^a_\mu$ is updated from time step $n{-}1$ to $n{+}1$ using the electric field $E^a_\mu$ evaluated at time $n$.
- The electric field $E^a_\mu$ is updated from $n{-}1$ to $n{+}1$ using the magnetic field $B^a_i$ and current $J^a_\mu$ evaluated at time $n$.
- The magnetic field $B^a_i$ is computed directly from the field strength tensor $F^a_{\mu\nu}$, which in turn is derived from $A^a_\mu$.

Therefore, $B^a_i$ at time $n$ must be computed using $A^a_\mu$ at time $n$.

This implies that the magnetic field at time $n$ must be computed *after* the gauge field $A^a_\mu$ is evolved to that time step, and *before* it is used to update the electric field $E^a_\mu$ at the next time step - resulting in the necessity to either performing re-computations and/or split the evolution into a multiple-pass process (introducing memory overhead and forcing a less-flexible architecture).

*Can a fully-accurate real-time update scheme be formulated without the tradeoffs outlined?*

To maintain a single-pass evolution, without recomputation or multiple synchronization steps, the key insight is to *introduce a relative offset* between the temporal representation of the gauge potentials' lattice buffer and the field-strengths' lattice buffers.

The relative temporal alignment between the different field buffers could be relaxed, letting the relative alignment between the fields could take the following form:

$$
\begin{array}{|l|c|c|c|c|}
\hline
\\
\text{Gauge-Potential  } (A_\mu) & ... & n{-}1 & n & n{+}1      \\
\\
\hline
\\
\text{Electric-Strength  } (E_i) & n{-}1 & n & n{+}1 & ...      \\
\\
\hline
\\
\text{Magnetic-Strength } (B_i) & n{-}1 & n & n{+}1 & ...      \\
\\
\hline
\end{array}
$$

Allowing, for instance, the temporal slope of the gauge potential $A^a_i$, which relies on itself and the electric-field-strength, to be computed using gauge potentials at $(n)$ and electric field strengths at $(n+1)$. Instaed of insisting it'd be computed via states taken from both lattice buffers at $(n)$.

This staggered alignment guarantees consistency, enables single-pass computation, and ensures numerical stability for both Abelian and non-Abelian gauge field dynamics within the Lorentz gauge.

## Update Rules

The final update rules would have the structure outlined in the theory developement above, incorporating the temporal alignment specified.

Initially, the denotation of the field strength tensor in the following relations would be made explicit in meaning:

$$
(F^a_{\mu\nu})^n=\partial_\mu (A_\nu^a)^n - \partial_\nu (A_\mu^a)^n - f^{abc} (A_\mu^b)^n (A_\nu^c)^n
$$

(Focusing on the temporal index $n$ explicitly expressing *from which temporal instance the gauge-potentials $A^a_\mu$ are taken*.)

The Magnetic-Field-Strengths $B^a_i$ would be trivially updated by writing the magnetic components of the field strength tensor computed on $(A^a)^n$ to the states $(B^a_i)^{n+1}$

$$
\boxed{\quad (B^a_i)^{n+1}=-\frac12\epsilon^{ijk}(F^a_{jk})^n \quad}
$$

The value of $\partial_0 E^a_\mu$ has been worked out in the theory development above (eq. $1.3.3$), allowing the substitution of the expression describing it into the relation in equation $(2.1.5)$ to obtain the evolution equation for $(E^a_\mu)^{n+1}$:

$$
\boxed{\quad(E_\mu^a)^{n+1} = (E_\mu^a)^{n-1} + 2 \Delta t \Big ((J^a_\mu)^n + [\vec \nabla \times (B^a)^{n}]_\mu - \Sigma_\nu g f^{abc} (A^b_0)^{n} (F^c_{\nu\mu})^{n}\Big)_{\mu \in \{1,2,3\}}\quad}
$$

In addition, the Electric field would need to be *divergence-cleaned* to satisfy:

$$
\boxed{\quad\vec\nabla\cdot (E^a)^{n+1} = (-J^a_0)^n + \Sigma_\nu g f^{abc} (A^b_0)^n (F^c_{\nu\mu})^n\quad}
$$

The value of $\partial_0 A^a_\mu$ has also been worked out in the theory development above (eq. $1.2.3$) for the spatial axes $\mu = \{1,2,3\}$, thus the expression describing it can be substituted into the relation in eq. $2.1.2$ to finally obtain the evolution of $(A^a_\mu)^{n+1}$:

$$
\boxed{(A_\mu^a)^{n+1} = (A_\mu^a)^{n-1} + 2\Delta t \Big((E^a_\mu)^{n+1} + \partial_\mu (A^a_0)^n + f^{abc}(A^b_0)^n (A^c_\mu)^n\Big)}
$$

Lastly, as the temporal component of the gauge field $(A^a_0)^{n+1}$ is still yet to be handled, the relation developed for its temporal slope would be used in the same way:

$$
\boxed{(A_0^a)^{n+1} = (A_0^a)^{n-1} + 2\Delta t (\partial_i A^a_i)}
$$

---

[⇥ Check out: A FieldForge compute-operation directly implementing the theory derived above](../../shaders/compute/gauge_evolution/evolve_gauge_fields-yang_mills_leapfrog.compute)

---

### Authors

[Idan Shemesh](https://github.com/IdanShmsh)
