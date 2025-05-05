### Implementation Guidelines

#### Always Should

TODO

#### Sometimes Could

- 

#### Never Would

- 

---

### Implementations

---

#### AmpT4RgfxEdNi

##### Description

This energy management implementation stabilizes the total energy of the simulation only by scaling the norms of lattice sites across all fields only taking away energy never directly increasing it. Accounts for the total simulation energy recorded across the 4 most recent temporal instances (frames) and obtains a 'current target total energy measurement' which represents the value that keeps the slope of the regression line going between those measurements near 0 (representing a conserved average energy)

##### Optimizations

No trade-off inducing optimizations.

##### Required Global Buffers

TODO

---

#### AmpT4RgfxEdNi

##### Description

TODO

##### Optimizations

No trade-off inducing optimizations.

##### Required Global Buffers

TODO
