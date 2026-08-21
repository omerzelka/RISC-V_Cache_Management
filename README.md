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
<img width="1465" height="799" alt="Ekran Resmi 2026-08-21 17 04 45" src="https://github.com/user-attachments/assets/4cc3631f-9216-4e9f-9862-b808ca306fc9" />
<img width="1469" height="798" alt="Ekran Resmi 2026-08-21 17 05 01" src="https://github.com/user-attachments/assets/b965dd0b-1add-4ccd-ba88-66180a1ae136" />
<img width="1463" height="53" alt="image" src="https://github.com/user-attachments/assets/9b733bc0-4f88-4ef6-897e-4121dee25a51" />


## ⚙️ Physical Design (RTL-to-GDSII)

The `cache.v` module was successfully synthesized into a physical layout using the **OpenLane** automated ASIC flow. 
*(Note: `main_memory.v` and `testbench.v` were intentionally excluded from synthesis as per industry standards for macros and test environments).*

**Configuration Details (`config.json`):**
*   **Process Node:** SkyWater 130nm (`sky130A`)
*   **Target Clock Period:** 10.0 ns (100 MHz)
*   **Target Density:** 0.40

### Final Layout (GDSII)
The synthesis, floorplanning, placement, and routing were completed without any Linter errors. The resulting `.gds` file was inspected using **KLayout**.

<img width="1940" height="1654" alt="image" src="https://github.com/user-attachments/assets/2638b6cc-4cf8-441f-ab01-fefb7271ebd2" />
*The final physical layout of the L1 Cache module, displaying the placement boundaries and routing layers.*

