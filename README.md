
# SRAM Built-In Self-Test (MBIST) Controller

## Overview

An FSM-based SRAM Built-In Self-Test (MBIST) controller implemented in Verilog HDL using the **March C- algorithm** for automated memory testing and fault detection.

The design performs systematic read and write operations across memory locations to identify memory faults. It is structured using modular RTL components and targets FPGA implementation on the **Xilinx Spartan-7** platform.

## Key Features

- FSM-based MBIST controller with seven states.
- March C- algorithm for systematic SRAM testing.
- 64 × 8-bit SRAM model (64 words, 8 bits per word).
- Automated address generation and memory read/write control.
- Data comparison for fault detection.
- Error logging for identifying faulty memory locations.
- Start, busy and done status signals.

## Architecture

The design consists of the following modules:

| Module | Description |
|---|---|
| `mbist_top.v` | Top-level integration of the MBIST system |
| `mbist_controller.v` | FSM implementing the March C- test sequence |
| `sram_model.v` | Behavioural SRAM model |
| `address_generator.v` | Generates memory addresses |
| `comparator.v` | Compares expected and actual read data |
| `error_logger.v` | Records detected memory errors |
| `tb_mbist.v` | Testbench for functional verification |

## March C- Algorithm

The controller executes the following memory test sequence:

1. Write 0 to all memory locations.
2. Read 0 and write 1 in ascending address order.
3. Read 1 and write 0 in ascending address order.
4. Read 0 and write 1 in descending address order.
5. Read 1 and write 0 in descending address order.
6. Read 0 from all memory locations.

The sequence helps detect several common SRAM faults, including stuck-at, transition and address-decoder faults.

## Design Specifications

| Parameter | Specification |
|---|---|
| Design | SRAM MBIST Controller |
| HDL | Verilog |
| Memory organisation | 64 × 8 bits |
| Address width | 6 bits |
| Data width | 8 bits |
| Test algorithm | March C- |
| Controller | 7-state FSM |
| Target FPGA | Xilinx Spartan-7 |

## Verification

The design was functionally verified using a Verilog testbench.

The testbench checks:
- Reset and initialization.
- MBIST start operation.
- March C- sequence execution.
- Memory read/write operations.
- Data comparison and error detection.
- Busy and done status signals.

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Xilinx Vivado
- Spartan-7 FPGA

## Learning Outcomes

- Finite State Machine (FSM) design.
- SRAM architecture and memory testing.
- March-based test algorithms.
- RTL modular design and verification.
- FPGA-oriented digital design.

## Future Scope

- Integration with physical SRAM macros.
- Implementation and testing on FPGA hardware.
- Extension to additional March test algorithms.
- Evaluation of fault coverage and test execution time.

---

**Project Focus:** Digital Design | Verilog HDL | FSM | SRAM Testing | MBIST | FPGA
