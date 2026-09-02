# Alt-Az full-motion QA sweep plan

This is the project-specific application of the generic [`MOTION_QA_PROTOCOL.md`](../MOTION_QA_PROTOCOL.md).

The mount must not be accepted from a few static poses alone. Both mechanical degrees of freedom must be checked across their intended ranges, including end limits and coupled configurations.

## M-ALT — altitude axis

Current documented range:

```text
-20° .. +90°
```

Mandatory exact review poses:

```text
-20°  lower end limit
0°    reference
45°   representative intermediate
90°   upper end limit
```

Full sweep:

- initial sampled interval: 5° from -20° through +90°;
- reduce to 1° or finer around any close-clearance or visually ambiguous region;
- if a collision/clearance transition is found, bracket and refine it until the boundary is understood;
- inspect with ALT guard both installed and removed/transparent where drive relationships are hidden.

At every ALT sample check:

- payload plate ↔ both yoke arms;
- payload/clamps ↔ yoke structure;
- payload ↔ fixed ALT gearbox/guard;
- ALT output stack ↔ fixed drive-side structure;
- shaft/bearing/output-stack axial coherence;
- current payload envelope and any future phone/optic adapter envelope.

## M-AZ — azimuth axis

Intended mechanical range:

```text
0° .. 360° continuous, including the 360° → 0° wrap
```

Full sweep:

- initial sampled interval: 10° over the complete revolution;
- explicitly include 0°/360° wrap;
- use finer sampling if any non-axisymmetric external geometry or cable routing approaches a fixed structure.

The current tabletop disk and AZ outer structure are largely rotationally symmetric, but this does **not** waive the sweep requirement. The moving yoke, payload and ALT gearbox must still be reviewed as one rotating upper assembly.

Cable routing has not yet been integrated as a frozen mechanical interface. Therefore the current M-AZ QA can establish rigid-body mechanical clearance, while continuous cable twist/strain remains a future explicit interface constraint once electronics/cabling enter scope.

## Coupled AZ × ALT configurations

Independent sweeps are necessary but not sufficient.

At minimum review the Cartesian critical set:

```text
AZ = 0°, 45°, 90°, 135°, 180°, 225°, 270°, 315°
ALT = -20°, 0°, 45°, 90°
```

This yields 32 mandatory coupled review configurations before considering the current two-axis assembly motion-QA-passed.

If a close-clearance state appears, refine around that AZ/ALT neighborhood rather than relying only on the 32-point grid.

## Tabletop-specific checks

For `A-TABLETOP-FULL`, every critical ALT state and representative AZ state must also be checked against the tabletop support envelope.

Rigid CAD collision checks are necessary but do not establish overturn stability. Physical tabletop verification remains separate and must include:

- actual payload mass;
- worst intended ALT orientation;
- realistic off-axis payload center of gravity;
- all four feet contacting the surface;
- no rocking;
- acceptable overturn margin.

## Evidence package

For the human review gate retain/regenerate at least:

- critical-pose contact sheet;
- lower ALT limit;
- upper ALT limit;
- neutral/reference pose;
- closest-clearance pose(s);
- representative coupled AZ/ALT poses;
- guard-off view of the ALT drive at critical states;
- any cutaway needed to understand a questionable clearance;
- machine-readable list of all sampled configurations and pass/fail result when tooling supports it.

## Acceptance rule

`A-FULL` / `A-TABLETOP-FULL` may be marked `MOTION_QA_PASS` only after:

1. full M-ALT sweep is complete;
2. full M-AZ sweep is complete;
3. the coupled critical grid is complete;
4. any suspicious region is adaptively refined;
5. no unintended rigid-body conflict is present;
6. remaining non-CAD constraints such as cable twist and physical tabletop stability are explicitly preserved as pending verification items.
