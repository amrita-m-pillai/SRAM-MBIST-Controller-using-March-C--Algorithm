
## Overview

An FSM-based SRAM Built-In Self-Test (MBIST) controller implemented in Verilog HDL using the **March C- algorithm** for automated memory testing and fault detection.

The design was synthesized and implemented on a **Xilinx Spartan-7 FPGA**, demonstrating the practical deployment of an RTL-based memory testing architecture on FPGA hardware.

## FPGA Implementation

- Synthesized and implemented the MBIST controller on a Xilinx Spartan-7 FPGA using Vivado.
- Integrated the controller, address generator, SRAM model, comparator and error logger.
- Implemented the seven-state FSM to execute the March C- test sequence.
- Validated the controller operation using the start, busy and done status signals.

## Verification

The design was simulated using Icarus Verilog and its waveforms were analysed using GTKWave. FPGA implementation was performed using Xilinx Vivado on the Spartan-7 platform.

Verification covered:
- Reset and initialization.
- MBIST start operation.
- March C- sequence execution.
- Memory read/write operations.
- Data comparison and error detection.
- Completion status and error reporting.
