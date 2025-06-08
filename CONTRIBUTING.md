# Contributing to FieldForge

Welcome to *FieldForge* — an experimental and modular platform for real-time spinor–gauge field simulations. We appreciate contributions from anyone who wants to expand, optimize, or extend the engine. Please read this guide to understand the development philosophy, coding conventions, and process for making changes.

---

## Overview

FieldForge is a GPU-driven simulation engine designed to visualize quantum-inspired field dynamics using *continuous classical approximations*. The simulation is implemented in *HLSL*, with platform-specific bindings (currently Unity + C#) used to interact with it.

The codebase is built around *clear functional structure*, with side-effects tightly controlled and explicitly declared. We aim to maximize *modularity*, *maintainability*, and *extensibility*, especially within the HLSL simulation engine.

[⇥ Read more about this project's technical structure and theoretical background](../Structure%20And%20Theory.md)

---

## General Contribution Workflow

All contributions to FieldForge trivially follow a strict *review-based pull request workflow*. This ensures code stability and shared understanding across the project.

- *All changes must be submitted via Pull Request*.
- *All PRs require at least one reviewer’s approval* before merging.
- *Direct commits to `main` are prohibited*.

### Steps

1. *Fork* the repository and create a branch:

   ```bash
   git checkout -b branch-name
   ```
2. *Make your changes*, ensuring they follow the code structure and documentation conventions listed above.
3. *Test locally* on a supported platform. For HLSL, Unity-based simulation runs are expected; for new bindings, a working test case must be provided.
4. *Open a Pull Request*, and include:

   - A clear *description* of what you’ve done.
   - Notes on *side effects* if you’ve modified HLSL logic.
   - Documentation updates if required (e.g. new shader pipeline, new field type, new interaction logic).
5. *Wait for review.*

   - Reviewers may request changes if:
     - Naming, structure, or style is inconsistent.
     - Comments are missing or misleading.
     - Side-effects are undocumented or hidden.
     - Code deviates from known physical theory without justification.
     - The change introduces unnecessary generality or premature abstraction.

### Branch Naming Convention

Branch names should begin with one of the following prefixes:


| Prefix      | Meaning                                                                        |
| ----------- | ------------------------------------------------------------------------------ |
| `core/`     | Changes to shared low-level utilities or buffer handling logic.                |
| `sim/`      | Field-theoretic implementations or updates to simulation dynamics.             |
| `render/`   | Visual or screen-space logic (e.g. fragment shaders, output tools).            |
| `infra/`    | Infrastructure changes (e.g. CI, file structure, configuration).               |
| `doc/`      | Documentation files or markdown updates.                                       |
| `test/`     | Unit tests, buffer validators, or temporary simulation probes.                 |
| `fix/`      | Targeted bug fixes.                                                            |
| `feat/`     | New features that do not belong to simulations.                                |
| `exp/`      | Experimental code not intended for stable merges (can be cleaned post-review). |
| `opt/`      | Performance or memory optimizations.                                           |
| `refactor/` | Code restructuring that preserves existing behavior.                           |

---

## Contributing Mindset

FieldForge is built to explore *unquantized, unmeasured field dynamics* — a space where physics, math, and interactivity collide. Contributions should embrace this experimental nature while *remaining precise*, *predictable*, and *explainable*.

> Don't generalize unless it's needed.
> Don't abstract unless it's reusable.
> Don't mutate unless it's justified.

---

## HLSL Engine: Contributing Guidelines

### Structure

- The HLSL code is organized as *namespaces of functions*, typically grouped by physical role or mathematical purpose.
- There are *no classes or structs* defining behavior. If you propose introducing one, you must *fully justify* the design and its alignment with simulation constraints.
- Most state is passed explicitly. Global variables exist, but they are:
  - *CPU-managed constants*, or
  - *Simulation buffers*, declared as `RWStructuredBuffer` or similar.

### Coding Style


| Element            | Convention     | Example                                   |
| ------------------ | -------------- | ----------------------------------------- |
| Functions          | `snake_case`   | `compute_energy_density`                  |
| Function arguments | `snake_case`   | `fermion_state`, `field_index`            |
| Local variables    | `snake_case`   | `energy`, `spatial_gradient`              |
| Global constants   | `CAPITAL_CASE` | `simulation_`                             |
| Namespaces         | `PascalCase`   | `DiracFormalism`, `FermionFieldEvolution` |

### Comments and Documentation

- Every *namespace* must include a description comment block.
- Every *namespace containing even a single function with side-effects* must indicate so explicitly in its comment block, e.g.:

  ```hlsl
  /// * Functions may read directly from and/or write directly to the simulation's lattice buffers and global values.
  ```
- Every *function* must include a description comment block.
- Every *function with side-effects* must indicate so explicitly in its comment block, e.g.:

  ```hlsl
  // * Side Effects:
  // • Reads directly from the simulation's lattice buffers
  // • Writes directly to the simulation's lattice buffers
  ```
- Informative internal comments are encouraged, but should be included selectively and only when they add clarity or insight.

  ✓ Good:

  ```hlsl
  // The following line computes the proper magnitude of the field at this location based on the theory outlined in <documentation.md>
  // This code is implicitly sensitive to the order of executions currently used. A brief explanation would be: ...
  // There's a minor deviation from the theory here, for the following purely technical reasons: ...
  ```

  ˟ Avoid:

  ```hlsl
  // This line break is for visual clarity  
  // Idk... someone would rewrite this
  // Didn't find a better way of doing this...
  ```

  Clarity is good — noise is bad.

---

### Theory-Based Implementation Development

Theory-Implementations are the beating heart of FieldForge.

While FieldForge is a platform for simulating quantum fields, it is more precisely a platform for expressing and evolving *theories* of such fields. FieldForge’s core establishes the environment: buffer structures, data handling, rendering interfaces, and numerical tools. But what *drives the simulation* — the actual dynamics, the physical principles — are encapsulated in *implementations*.

Every implementation represents a *theory*, and development begins with that theory.

#### Step 1: Document the Theory

If the theory you're about to implement *already exists* in FieldForge’s documentation and you're only improving or extending it, you may update the corresponding `.md` file with your extension and justification.

If you're implementing a *new concept or model*, you must first:

- Write a complete `.md` document formally developing the theory behind it.
- Include derivations, discretization schemes, and rationale for any simplifications.
- This document must be committed *before any code is submitted*.

> FieldForge is a research-grade simulation engine — its implementations must be backed by clearly stated theoretical principles, not just code.

#### Step 2: Write the Implementation

Create an HLSL file and namespace that *faithfully implements* the documented theory using FieldForge's core utilities. Modify or extend the core only as needed, and always in accordance with general design guidelines.

Then, write a *single compute shader* that directly executes the implementation’s logic.

Your changes should:

- Match the modular structure seen in other implementations.
- Integrate with FieldForge’s temporal evolution and buffer update schemes.
- Be isolated, clean, and reviewable.

Branches that contain work on implementations should be prefixed with:

```bash
sim/your-implementation-name
```

---

## Platform Bindings: Contributing Guidelines

Platform bindings connect the FieldForge HLSL simulation engine to runtime environments. The current implementation binds to *Unity (C#)*, but contributors are welcome to provide bindings for other platforms (e.g. WebGPU, Vulkan, Unreal, or native C++ apps).

### Goals

- Provide *clean separation of concerns*: avoid mixing simulation logic, user interaction, and rendering behavior in the same class or file.
- Respect the functional design of the engine: *don’t wrap simulation logic in opaque stateful managers* unless absolutely necessary.
- Be as *modular and reusable* as possible — especially if adding new simulation contexts (e.g. different physics pipelines or visualizations).

### Requirements for New Bindings

If you introduce a new platform or API binding:

- Include a *README* in the corresponding folder explaining how it works and how to run it.
- Provide at least *one working example scene or script* demonstrating correct operation.
- Use *structured layout and naming*, following the conventions of the platform (e.g. `PascalCase` for C# classes and methods).
- *Avoid tight coupling* to Unity or any particular engine feature unless justified. Code should ideally be portable or engine-agnostic.

### Unity-Specific Notes

- *Bindings to HLSL should be minimal and direct* — avoid unnecessary intermediate wrappers or manager monoliths.
- Organize Unity-side logic into:
  - `SimulationControl`: for triggering shader passes and dispatch sequences
  - `UIBindings`: for user input and control exposure
  - `FieldSync`: for synchronizing buffer content to and from the GPU
- Prefer *jobs, burst, and compute* wherever possible; avoid blocking calls on the main thread.

---

Thanks for helping build FieldForge!
