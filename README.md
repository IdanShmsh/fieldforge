# FieldForge

FieldForge is a real-time simulation framework for evolving quantum fields as unobserved, unquantized dynamical entities on a discrete spacetime lattice. It enables direct, interactive encoding and execution of field-theoretic evolution laws taken directly from the standard model of quantum mechanics, including spinor fields, gauge fields, and their couplings, entirely on the GPU via compute shader bindings.

FieldForge does not simulate measurement outcomes. It does not sample from probabilistic distributions. Instead, it exposes the underlying structure and evolution of quantum field dynamics as they would proceed in the absence of observation, quantization, or approximation. The simulation remains entirely classical and local, allowing full visual access to formal field behavior at the level of raw structure.

The system is designed to support theory-backed implementations, allowing rapid iteration and testing of dynamic field behavior. While the architecture preserves fidelity to the underlying mathematics, FieldForge prioritizes interactivity and extensibility over high-precision numerical accuracy.

---

## Visual Demonstration

FieldForge includes a real-time visual interface that renders the live state of the simulated fields. Fields can be externally perturbed to explore their response, or left to evolve freely to exhibit emergent structure.

The gallery below shows live captures from FieldForge simulations:

<p align="center">
  <h4>Charged Fermion/Anti-Fermion Pair In A Uniform Depth-Oriented Magnetic Field</h4>
  <img src="assets/gifs/Magnetic.gif" width="300" alt="Fermion-U1 Uniform Magnetic Coupling"/>
  <h4>Charged Fermion Packet Reacting To An Abruptly Activated Electric Monopole</h4>
  <img src="assets/gifs/Coloumb.gif" width="300" alt="Fermion-U1 Monopole Electric Coupling"/>
  <h4>Massive Fermion Packet Passing Through A Double Slit Barrier</h4>
  <img src="assets/gifs/Doubleslit.gif" width="300" alt="Fermion Double Slit"/>
  <h4>Particle/Anti-Particle Pair Scattering In A Non-Trivial/Time-Evolving U1 Potential</h4>
  <img src="assets/gifs/Interaction.gif" width="300" alt="Fermion-U1 Potential Coupling"/>
  <h4>Fermion Packets With Equal Mass-Different Momentum Tunneling Through A Potential Barrier</h4>
  <img src="assets/gifs/Tunneling.gif" width="300" alt="Fermion Barrier Tunneling"/>
  <h4>Free Evolution Of Perturbed Electromagnetic Fields</h4>
  <img src="assets/gifs/EM.gif" width="300" alt="Free Fermion Fields"/>
  <h4>Free Evolution Of Perturbed Fermion Field</h4>
  <img src="assets/gifs/Fermion.gif" width="300" alt="Fermion-U1 Potential Coupling"/>
</p>

Each frame is fully determined by the encoded theory - no randomness, no noise, no render approximations -  simulations are accurate up to machine precision.

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

### Core Capabilities

These elements form the backbone of FieldForge’s theoretical engine. They provide the definitions, structures, and mathematical mechanisms required for the simulation’s high-fidelity evolution and internal coherence.

- **Dirac Formalism (Spinor Structure)** - Provides the algebraic backbone for spinor field dynamics. Includes gamma matrix contraction rules, spinor symmetry properties, and the structural representation of spin and Lorentz transformations. This formalism defines how spinor states evolve, interact, and transform under symmetry operations.

- **Yang-Mills Formalism (Gauge Field Theory)** - Encodes the structure of interacting gauge fields. Includes the full tensorial definition of the field strength, non-commutative gauge potentials, and structure constants of the underlying Lie algebra. Supports both free-field evolution and interaction with matter via covariant derivatives and currents.

- **Wilson Formalism (Geometric Gauge Transport)** - Describes gauge interaction through parallel transport between adjacent lattice sites. Link variables encode local gauge transformations, ensuring that neighbor comparisons and current extractions remain gauge covariant. This formalism is central to all interaction logic and supports both abelian and non-abelian symmetries.

### Simulation Processes

These are the real-time processes executed during simulation. Each one corresponds to a distinct standalone processes running on the GPU as an independent pipeline stage.

- **Dirac Fermion Evolution** - Evolves a spinor-valued fermion field on the lattice using a leapfrog scheme derived from the Dirac equation. Spinor components are time-staggered to ensure second-order accuracy. Local gauge interactions are applied through parallel transport, ensuring gauge invariance across discrete neighbor accesses.

- **Yang-Mills Gauge Evolution** - Evolves non-Abelian gauge fields using discretized Yang-Mills equations. Electric and magnetic field components are offset in time and updated using the field strength tensor. Self-interactions are implemented via the Lie algebra structure, and coupling to matter fields occurs through dynamically computed currents.

- **Barriers (Reflective and Absorbing)** - Static boundary structures placed within the simulation domain. These walls interrupt field propagation either by reflecting field components or absorbing energy, allowing spatial shaping of wave behavior.

- **Poking (Real-Time Perturbations)** - Fields may be perturbed during simulation by localized external input. This enables the injection of disturbances such as impulses, waves, or pulses, allowing users to observe reactive behavior and response propagation in real time.

### Rendering Abilities

Visual presentation is central to this project's main objective - exposing the underlying classical-like structure of quantum fields and their interaction. FieldForge provides a wide range of independent stackable renderers unlocking a massive collection of possible visualizations.

- **Fermion Renderers** - Allow rendering properties (phase, amplitude, dirac-norm, spin-state...) of the fermion fields in the simulation bringing out different aspects of structure.

- **Gauge Renderes** - Allow rendering the different symmetry-associated vector-fields (gauge-potential, field strengths...) in the simulation in several ways (lattice of dials, vector components mapped to RGB channels etc...) conceptualizing behavior with different approaches.

- **Effects and Filters** - Make renders even more visually appealing and engaging.

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
