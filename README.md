# Parameterized UART Module Verilog Implementation

## Overview
This project implements a robust, fully parameterized, and synthesizable UART (Universal Asynchronous Receiver-Transmitter) controller in Verilog. Designed with a modular architecture, it features dynamic clock scaling, midpoint start-bit centering, and automated handshake verification using an internal loopback testbench.

## Components
The design is modular, consisting of four primary building blocks:
- `Tx.v` (Transmitter): Manages the 8N1 serial transmission protocol, featuring a parameterizable baud rate generator and shift-register serialization.
- `Rx.v` (Receiver): Implements midpoint start-bit sampling (`MID_POINT`) for robust noise immunity and assembles incoming serial bitstreams back into parallel bytes.
- `Producer.v` (Data Generator): Continuously generates an incrementing sequence of data bytes and handshakes with the transmitter using the `txbusy` signal.
- `Top.v` (Top-level): Integrates the Producer, Transmitter, and Receiver into a complete system supporting external or loopback connections.

## Simulation
The software stack used is:
- Icarus Verilog: Used for compilation and simulation.
- GTKWave : Used for waveform visualization
### How to run:
To compile and run the provided testbench, use the following commands in your terminal:
```bash
# Compile the design
iverilog -o dsn testbench.v top_module.v Tx.v Rx.v Producer.v
# Run the simulation
vvp dsn
# Open the waveform in GTKWave
gtkwave top.vcd
```
## Waveform Analysis
The design's correctness is verified through the provided GTKWave simulation trace. The system relies on precise temporal alignment and baud tick generation, which are parameterized to support flexible simulation speeds.

**Figure 1: Full System Stream Overview**
<img width="1798" height="163" alt="Screenshot from 2026-07-21 14-08-26" src="https://github.com/user-attachments/assets/f3ac7058-33cb-4937-b472-22b17b00bb62" />
- System Synchronization: As observed in the waveform, the system clock (`clk`) and reset (`rst`) cleanly initialize the internal state machines.
- Continuous Stream: The `txline` and `rxline` demonstrate continuous byte packet serialization and loopback reception without data loss.

**Figure 2: Single Byte Transmission Detail (Tx)**
<img width="1796" height="171" alt="image" src="https://github.com/user-attachments/assets/53ade2e0-a75d-4b2f-9e20-539221b75f03" />
- Start and Stop Bits: The transmitter correctly drops the serial line low for the start bit, shifts out 8 data bits least-significant-bit (LSB) first via `tx_data_buffer`, and returns the line high during the stop state.
- Handshaking: The `txbusy` signal accurately tracks the transmission window, allowing the producer to trigger sequential bytes seamlessly.

**Figure 3: Receiver Midpoint Sampling (Rx)**
<img width="1796" height="171" alt="image" src="https://github.com/user-attachments/assets/9e330455-c9f7-44ac-85d3-ac7824596dcd" />
- Midpoint Alignment: The receiver samples the incoming start bit at its exact center (`MID_POINT`) to filter out noise before locking into the data window.
- Packet Completion: The packet_recieved (`rx_done`) flag pulses high precisely when the stop bit is validated, latching the correct byte onto received_data.

## Results
- Correct parameterized 8N1 UART serial loopback transmission verified via simulation
- Proper baud tick generation, midpoint start-bit sampling, and producer handshaking observed across the system
- Clean waveform capture achieved using accelerated simulation clock ratios
