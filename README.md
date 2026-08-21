This repository contains the RTL design, simulation, and physical synthesis (RTL-to-GDSII) of an **L1 Cache and Main Memory Controller**, written in **Verilog**. 

The project demonstrates a complete hardware engineering cycle: starting from writing the architectural logic, overcoming complex simulator-level race conditions, and successfully pushing the design through the **OpenLane** flow to generate a physical layout using the **SkyWater 130nm PDK**.

## 🚀 Features & Architecture

*   **Custom FSM (Finite State Machine):** Implements a robust state machine (`IDLE`, `COMPARE`, `ALLOCATE`, `WRITE_MEM`) for accurate cache operations.
*   **Latency Simulation:** The `main_memory.v` module includes an intentional 10-clock-cycle delay mechanism to realistically simulate the speed gap between the CPU and RAM.
*   **Write-Through Policy:** Handles data updates directly through the hierarchy.
*   **Continuous Assignment Resolution:** The design specifically separates output signals (`mem_ready`, `mem_req`, `cpu_ready`) from the `always @(*)` blocks using `assign` statements to prevent phantom delta-cycle loops and simulator deadlocks.

## 📊 Simulation & Waveforms

The design was rigorously tested using **Icarus Verilog** and **GTKWave/VCDrom**. The linear testbench (`testbench.v`) simulates three core scenarios: Cache Miss, Cache Hit, and Write-Through.

### Test Scenarios in Action
*Here are the waveform captures demonstrating the successful execution of the FSM and data transfer processes:*

![Cache Hit and Miss Operations](Ekran%20Resmi%202026-08-21%2017.05.24.jpg)
*Figure 1: Cache Miss followed by an immediate Cache Hit, showing the precise address parsing and data fetching.*

![Latency and Data Transfer](Ekran%20Resmi%202026-08-21%2017.05.01.jpg)
*Figure 2: The `delay_counter` in action, successfully passing `128'h4444...1111` dummy data after 10 clock cycles.*

![Complete System Overview](Ekran%20Resmi%202026-08-21%2017.04.45.jpg)
*Figure 3: A full system overview of the testbench, showcasing stable clock generation and synchronized `ready` signals without simulation hangs.*

## ⚙️ Physical Design (RTL-to-GDSII)

The `cache.v` module was successfully synthesized into a physical layout using the **OpenLane** automated ASIC flow. 
*(Note: `main_memory.v` and `testbench.v` were intentionally excluded from synthesis as per industry standards for macros and test environments).*

**Configuration Details (`config.json`):**
*   **Process Node:** SkyWater 130nm (`sky130A`)
*   **Target Clock Period:** 10.0 ns (100 MHz)
*   **Target Density:** 0.40

### Final Layout (GDSII)
The synthesis, floorplanning, placement, and routing were completed without any Linter errors. The resulting `.gds` file was inspected using **KLayout**.

![KLayout GDSII View](Ekran%20Resmi%202026-08-21%2017.58.29.png)
*Figure 4: The final physical layout of the L1 Cache module, displaying the placement boundaries and routing layers.*

## 🛠️ How to Run

### 1. Simulation (macOS / Linux)
Ensure you have `iverilog` installed.
```bash
# Compile the files
iverilog -o sim_cache cache.v main_memory.v testbench.v

# Execute the simulation
vvp sim_cache
