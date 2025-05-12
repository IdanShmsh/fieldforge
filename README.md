# FieldForge

---

## Table Of Contents

- [About](#about)
- [Gallery](#gallery)
- [Structure And Theory](#structure-and-theory)
  - [Architecture](#architecture)
  - [Formalisms and Implementation](#formalisms-and-implementation)

---

## About

***What would quantum fields look like if we could *see* them without *observing* them?***

FieldForge is a real-time simulation platform for exploring quantum fields - *visually*, *interactively*️, and *structurally*.

To make this possible, FieldForge intentionally abandons two defining features of quantum theory:

- **No quantization** - fields are treated as continuous, *deterministic* entities.
- **No measurement** - there is no collapse, no projection; the fields evolve *unobserved*.

This means FieldForge is **not** a scientific modeling tool in the strict sense. Instead, it is:

- A **research ground** for experimenting with quantum-inspired dynamics, symmetries, and interactions.
- A **modular platform** for implementing and/or configuring any formulation, modification, or reinterpretation of quantum field behavior.
- A **development environment** where simulation logic can be extended, replaced, or entirely reimagined — from first principles to visual output.

FieldForge is designed for probing the structure of quantum fields without the constraints of measurement or quantization.

---

## Gallery

*The following were captured in real time using FieldForge*

<img src="assets/gifs/free_fermion_fields.gif" width="300" alt="Free Fermion Fields"/>
<img src="assets/gifs/fermion_double_slit.gif" width="300" alt="Fermion Double Slit"/>
<img src="assets/gifs/free_electromagnetic_gauge_potential.gif" width="300" alt="Free U1 Gauge Potential"/>
<img src="assets/gifs/fermion+u1_gauge.gif" width="300" alt="Fermion-U1 Potential Coupling"/>

---

## Structure And Theory

### Architecture

FieldForge has a *modular architecture*, allowing the same underlying theoretical processes to be explored through a variety of technical implementations. These implementations can differ in complexity, approximation schemes, and optimization strategies, providing flexibility to suit various research interests and computational capabilities. At its core, FieldForge employs a structured compute-shader pipeline, offering precise, real-time control over the simulation’s runtime behavior.

Central to FieldForge’s computational approach are its field lattice buffers, which store discrete field states at each lattice site.

Each lattice site encodes:

- **Fermion fields**: represented as color-charged Dirac spinors, structured as arrays of 12 complex numbers (4 spinor components × 3 color charge components).
- **Gauge fields** / **Electric Field Strengths** / **Magnetic Field Strengths**: stored as sets of 12 4-vectors, each corresponding to a one of the 12 gauge symmetries of the Standard Model.

FieldForge maintains dedicated lattice buffers to store the states of these fields across three consecutive temporal instances: 'previous', 'current', and 'next'. This structured buffering enables stable, accurate time-evolution of the simulated fields.

Simulation parameters governing runtime conditions are explicitly defined. For instance:

- Spatial Dimensions: Number of lattice points along each axis (width, height, depth) defining the simulation volume.
- Spatial and Temporal Resolution: The fundamental spatial discretization (dx) and temporal discretization (dt) scales, determining simulation granularity.
- Interaction Strengths: Coupling constants governing the strength of gauge field self-interactions.
- Field Density Limits: Constraints on fermion and gauge field amplitudes, ensuring numerical stability.
- Field Visibility and Rendering: Settings for selectively visualizing fields and controlling visual brightness in real-time rendering.
- Configured Properties Of Fermion Fields: masses, rendering base colors, coupling constants.

### Formalisms and Implementation

FieldForge simulations enforce theoretical constraints by calculating states for subsequent temporal instances from well-defined dynamical equations and theoretical formalisms.

***- Example***

The dynamics of a free fermion field are given by the Dirac equation, from which, one explicitly obtains a time-derivative relation:


<p align="center">
<img src="https://latex.codecogs.com/gif.latex?(\gamma^\mu \partial_\mu - i m)\psi = 0 \implies \partial_0 \psi = \gamma^0(im - \gamma^i \partial_i)\psi"/>
</p>

In FieldForge, this theoretical relation might be realized through numerically approximating the right hand side via computations performed on the current lattice configuration, and then choosing an appropriate fermion state for the next time step such that the temporal derivative computed using a finite difference involving it remains consistent with the outlined theoretical relation.

Gauge field evolution and Dirac–Gauge interactions will follow a similar conceptual translation from theory to numerical implementation. Gauge fields require dedicated caching of electric and magnetic field strengths, continuously updated to maintain consistency and gauge invariance.

Interaction terms are naturally embedded by upgrading simple finite-difference derivatives to gauge-covariant derivatives, typically implemented through combinations of finite differences and Wilson lines, thus faithfully preserving gauge symmetry throughout the simulation.

The above illustrates merely a single approach for an implementation of dynamics in FieldForge, though, as mentioned - any working approach compatible with FieldForge's generic infrastructure is allowed.

[⇥ Read More About: Structure and Theory](docs/theory/Structure%20and%20Theory.md)
