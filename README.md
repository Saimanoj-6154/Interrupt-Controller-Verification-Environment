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

## Repository Structure

```
irq-controller-verif/
├── README.md
├── LICENSE
├── .gitignore
├── Makefile                          
├── docs/
│   ├── dut_spec.md                   
│   ├── verification_plan.md          
│   ├── testplan_to_coverage_map.md   
│   └── env_architecture.md           
│
├── rtl/
│   └── dut/
│       ├── irq_controller.sv         
│       ├── priority_arbiter.sv
│       └── claim_complete_fsm.sv
│
├── verif/
│   ├── uvm/
│   │   ├── agents/
│   │   │   ├── intr_src_agent/
│   │   │   │   ├── intr_src_driver.sv
│   │   │   │   ├── intr_src_monitor.sv
│   │   │   │   ├── intr_src_sequencer.sv
│   │   │   │   └── intr_src_item.sv
│   │   │   ├── reg_agent/            
│   │   │   │   ├── reg_driver.sv
│   │   │   │   ├── reg_monitor.sv
│   │   │   │   └── reg_item.sv
│   │   │   └── target_intr_agent/   
│   │   │       └── target_intr_monitor.sv
│   │   ├── env/
│   │   │   ├── irq_env.sv
│   │   │   ├── irq_env_config.sv
│   │   │   ├── irq_virtual_sequencer.sv
│   │   │   ├── irq_ref_model.sv      
│   │   │   ├── irq_scoreboard.sv
│   │   │   └── irq_coverage.sv
│   │   ├── sequences/
│   │   │   ├── virtual_seq/
│   │   │   │   ├── base_vseq.sv
│   │   │   │   ├── random_storm_vseq.sv        
│   │   │   │   ├── priority_tie_vseq.sv        
│   │   │   │   ├── threshold_masking_vseq.sv
│   │   │   │   ├── nested_preemption_vseq.sv
│   │   │   │   └── claim_complete_race_vseq.sv
│   │   │   └── src_seq/
│   │   │       └── intr_src_seq_lib.sv
│   │   └── tests/
│   │       ├── irq_base_test.sv
│   │       ├── smoke_test.sv
│   │       ├── priority_stress_test.sv
│   │       ├── threshold_masking_test.sv
│   │       ├── claim_complete_race_test.sv
│   │       └── regression_test_list.f
│   └── sva/
│       ├── claim_legality_assertions.sv   
│       ├── no_double_claim_assertions.sv
│       └── priority_ordering_assertions.sv
│
├── sim/
│   ├── questasim/
│   │   └── run_uvm.do
│   └── vcs/
│       └── run.sh
│
├── regression/
│   ├── run_regression.py             
│   ├── coverage_merge.py
│   └── report_gen.py                 
│
├── scripts/
│   └── waveform_gen.sh
│
└── .github/
    └── workflows/
        └── ci.yml                    
```

---

## Tools

- A UVM-capable simulator (Questa/VCS) — this environment is UVM-1.2 based
- Python 3.10+ (regression runner, coverage/report scripts)
- GTKWave or simulator-native waveform viewer for debug


