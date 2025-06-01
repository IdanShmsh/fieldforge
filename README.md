# FieldForge

FieldForge is a real-time simulation framework for evolving quantum fields as unobserved, unquantized dynamical entities on a discrete spacetime lattice. It enables direct, interactive encoding and execution of field-theoretic evolution laws taken directly from the standard model of quantum mechanics, including spinor fields, gauge fields, and their couplings, entirely on the GPU via compute shader bindings.

FieldForge does not simulate measurement outcomes. It does not sample from probabilistic distributions. Instead, it exposes the underlying structure and evolution of quantum field dynamics as they would proceed in the absence of observation, quantization, or approximation. The simulation remains entirely classical and local, allowing full visual access to formal field behavior at the level of raw structure.

The system is designed to support theory-backed implementations, allowing rapid iteration and testing of dynamic field behavior. While the architecture preserves fidelity to the underlying mathematics, FieldForge prioritizes interactivity and extensibility over high-precision numerical accuracy.

---

## Core Architecture

FieldForge is built around a modular lattice simulation pipeline with support for:

- Persistent field buffers with leapfrog-staggered temporal updates
- Independent evolution modules for spinor and gauge fields
- Explicit current calculation for back-reaction coupling
- Configurable regulation layers (e.g., amplitude constraints, energy density smoothing)
- Shader-based interactivity (perturbations, pokes, boundary conditions)

Each pipeline process (e.g. fermion evolution, gauge evolution, current extraction) is implemented as an independent HLSL compute shader. The simulation is designed to support multiple interchangeable implementations per process, allowing exploration of new theories or dynamics within the same system.

---

## Implemented Theories and Features

### Simulation Processes

These are the real-time processes executed during simulation. Each one corresponds to a distinct standalone processes running on the GPU as an independent pipeline stage.

- **Dirac Fermion Evolution** - Evolves a spinor-valued fermion field on the lattice using a leapfrog scheme derived from the Dirac equation. Spinor components are time-staggered to ensure second-order accuracy. Local gauge interactions are applied through parallel transport, ensuring gauge invariance across discrete neighbor accesses.

- **Yang-Mills Gauge Evolution** - Evolves non-Abelian gauge fields using discretized Yang-Mills equations. Electric and magnetic field components are offset in time and updated using the field strength tensor. Self-interactions are implemented via the Lie algebra structure, and coupling to matter fields occurs through dynamically computed currents.

- **Barriers (Reflective and Absorbing)** - Static boundary structures placed within the simulation domain. These walls interrupt field propagation either by reflecting field components or absorbing energy, allowing spatial shaping of wave behavior.

- **Poking (Real-Time Perturbations)** - Fields may be perturbed during simulation by localized external input. This enables the injection of disturbances such as impulses, waves, or pulses, allowing users to observe reactive behavior and response propagation in real time.

### Core Capabilities

These elements form the backbone of FieldForge’s theoretical engine. They provide the definitions, structures, and mathematical mechanisms required for the simulation’s high-fidelity evolution and internal coherence.

- **Fermion Current Extraction** - Computes the gauge-covariant Dirac current $\bar{\psi} \gamma^\mu \psi$, a key quantity used to drive gauge field evolution. Currents are calculated with geometric consistency, ensuring correct transformation under gauge symmetries and proper conservation in coupled systems.

- **Wilson Formalism (Geometric Gauge Transport)** - Describes gauge interaction through parallel transport between adjacent lattice sites. Link variables encode local gauge transformations, ensuring that neighbor comparisons and current extractions remain gauge covariant. This formalism is central to all interaction logic and supports both abelian and non-abelian symmetries.

- **Dirac Formalism (Spinor Structure)** - Provides the algebraic backbone for spinor field dynamics. Includes gamma matrix contraction rules, spinor symmetry properties, and the structural representation of spin and Lorentz transformations. This formalism defines how spinor states evolve, interact, and transform under symmetry operations.

- **Yang-Mills Formalism (Gauge Field Theory)** - Encodes the structure of interacting gauge fields. Includes the full tensorial definition of the field strength, non-commutative gauge potentials, and structure constants of the underlying Lie algebra. Supports both free-field evolution and interaction with matter via covariant derivatives and currents.

### Non-Formal Accessories

While not strictly part of the theoretical engine, these utility modules support visualization, numerical conditioning, and diagnostic clarity.

- **Field Blurring** - Local spatial smoothing operators that reduces sharp discontinuities and approximates coarse-grained dynamics. Often used to visualize average field motion or to regularize chaotic evolutions.

- **Field Denoising** - Selective filtering processes that preserves global structure while removing localized oscillations. Improves visual legibility and simulation clarity during high-frequency interaction phases.

- **Energy Manipulation** - Tools for adjusting the energy density of fields, either by scaling amplitudes or redistributing energy across the lattice. Useful for exploring stability and response to perturbations.

Each implementation is derived directly from formal field equations and discretized to preserve local structure.

---

## Foundational Assumptions

FieldForge operates under the following foundational constraints:

- **Unquantized fields:** All field variables are continuous and deterministic. There are no probability amplitudes, path integrals, or operator algebra.
- **Unmeasured dynamics:** The system evolves as if never observed. There is no collapse, no projection, no Born rule.
- **Explicit theories:** Every field behavior is implemented by a specific, derivable equation encoded as a discrete numerical update.
- **Composability:** The simulation structure is modular. New dynamics may be encoded by swapping or extending implementation shaders without modifying the core.

This philosophical framework positions FieldForge not as a tool for predictive modeling, but as a platform for *structural exploration* — a space where the inner logic of quantum field dynamics is made accessible and manipulable.

---

## Visual Demonstration

FieldForge includes a real-time visual interface that renders the live state of the simulated fields. Fields can be externally perturbed to explore their response, or left to evolve freely to exhibit emergent structure.

The gallery below shows live captures from FieldForge simulations:

<p align="center">
  <img src="assets/gifs/fermion+u1_gauge.gif" width="300" alt="Fermion-U1 Potential Coupling"/>
  <img src="assets/gifs/fermion_phases_and_dials.gif" width="300" alt="Free Fermion Fields"/>
  <img src="assets/gifs/gauge_vector_potential.gif" width="300" alt="Free Fermion Fields"/>
  <img src="assets/gifs/free_fermion_fields.gif" width="300" alt="Free Fermion Fields"/>
  <img src="assets/gifs/fermion_double_slit.gif" width="300" alt="Fermion Double Slit"/>
  <img src="assets/gifs/free_electromagnetic_gauge_potential.gif" width="300" alt="Free U1 Gauge Potential"/>
</p>

Each frame is fully determined by the encoded theory — no randomness, no noise, no render approximations.

---

## Intended Use

FieldForge is designed for:

- **Theoretical physicists** exploring new structures in field evolution
- **Simulation developers** implementing real-time lattice physics
- **Educators** seeking visual demonstrations of field behavior
- **Experimental thinkers** testing structural extensions to known formalisms

While no prior quantum field theory knowledge is required to run the system, the framework rewards those familiar with the formal language of spinors, gauge symmetry, and classical field evolution.

---

## Contributing

FieldForge supports the development of new field-theory implementations through a modular system. Each implementation encodes a specific theoretical formalism and must adhere to FieldForge’s input-output conventions and temporal staggering model.

To contribute a new implementation or module, refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file for theoretical, structural, and technical guidelines.

---

## Learn More

[⇥ Theory & Discretization](docs/theory/Structure%20And%20Theory.md)

[⇥ Contributing](CONTRIBUTING.md)

[⇥ Fermion Evolution Spec](docs/fermion_evolution.md)

[⇥ Gauge Evolution Spec](docs/gauge_evolution.md)

---

## Licensing

- Simulation Code: **GPLv3**
- Documentation & Visual Assets: **CC BY-NC 4.0**

---

## Author

[Idan Shemesh](https://github.com/IdanShmsh)
