# Interrupt-Controller-Verification-Environment

A complete UVM-based verification environment for a SoC-style interrupt
controller (PLIC/GIC-like: multiple interrupt sources, priority
arbitration, per-target enable/threshold, claim/complete handshaking).
Built as a standalone DV project to demonstrate SoC-level verification
methodology on a small but genuinely tricky-to-verify piece of hardware.

## Overview

- **DUT**: parametrized interrupt controller — N interrupt sources, M
  targets/harts, per-source priority, per-target threshold, claim/
  complete protocol (PLIC-style), nested/preemption behavior
- **UVM environment**: layered agents, virtual sequencer, reference
  model, scoreboard, functional coverage — reusable across DUT
  variants via the config object
- **Stimulus**: constrained-random interrupt generation (arbitrary
  timing, priority, simultaneity across sources) plus directed
  corner-case sequences
- **Reference model**: a transaction-level predictor that computes
  expected claim order and pending/enabled state independently of the
  RTL, for scoreboard comparison
- **Coverage-driven closure**: functional coverage model tracks
  priority collisions, simultaneous multi-source assertion, threshold
  masking, claim/complete ordering, and back-to-back interrupt storms
- **Assertions (SVA)**: protocol-level invariants — no claim without a
  pending+enabled source, no double-claim of the same interrupt ID,
  priority ordering never violated at arbitration
- **Regression**: scripted regression list with coverage merge and
  HTML report generation
## Verification Environment Architecture

```
                        ┌──────────────────────┐
                        │   Test (uvm_test)     │  selects sequence(s),
                        │                        │  configures env
                        └───────────┬───────────┘
                                    ▼
                        ┌──────────────────────┐
                        │  Virtual Sequencer    │
                        └───────────┬───────────┘
                                    ▼
                        ┌──────────────────────┐
                        │        Env             │
                        │  ┌─────────────────┐  │
                        │  │  intr_src_agent  │  │  drives/monitors N
                        │  │  (driver/mon/seqr)│ │  interrupt source lines
                        │  └────────┬────────┘  │
                        │  ┌────────▼────────┐  │
                        │  │  reg_agent (APB/ │  │  claim/complete,
                        │  │  AHB-lite driver) │  │  enable/threshold regs
                        │  └────────┬────────┘  │
                        │  ┌────────▼────────┐  │
                        │  │ target_intr_mon  │  │  monitors interrupt-out
                        │  │  (per target)    │  │  signals to each target
                        │  └────────┬────────┘  │
                        │           ▼            │
                        │  ┌──────────────────┐  │
                        │  │  Reference Model  │  │  predicts claim order,
                        │  │                    │ │  pending/enable state
                        │  └────────┬──────────┘  │
                        │           ▼              │
                        │  ┌──────────────────┐   │
                        │  │   Scoreboard      │   │  compares RTL vs. model
                        │  └──────────────────┘   │
                        │  ┌──────────────────┐   │
                        │  │ Coverage Collector │  │  functional coverage
                        │  └──────────────────┘   │
                        └──────────────────────┘
```

---
