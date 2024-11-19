# ECC ErrorCorrectionCodes  

This repository provides a comprehensive implementation of Error Correction Codes (ECC) in VHDL. It includes modular components, and encoders/decoders for Hamming Code (in both gate-based and matrix-based approaches) and Hadamard Code.  

---

## Table of Contents  
1. [Repository Structure](#repository-structure)  
   - [Components](#1-components)  
   - [Source](#2-source)  
     - [HammingCode (Initial Versions)](#21-hammingcode-initial-versions)  
     - [HammingCode (Matrix Method)](#22-hammingcode-matrix-method)  
     - [HadamardCode](#23-hadamardcode)  
2. [Features](#features)  
3. [Tools and Hardware](#tools-and-hardware)  
4. [How to Use](#how-to-use)  
   - [Clone the Repository](#1-clone-the-repository)  
   - [Navigate to the Desired Folder](#2-navigate-to-the-desired-folder)  
   - [Compile and Simulate](#3-compile-and-simulate)  
   - [Run on Hardware](#4-run-on-hardware)  
5. [Testing and Verification](#testing-and-verification)  
6. [Future Enhancements](#future-enhancements)  

---

## Repository Structure  

### 1. **Components**  
This folder contains reusable VHDL components that form the building blocks for the ECC package. These components are used across all implementations.  

**Included Components**:  
- Logic Gates: `and`, `or`, `not`, `xor`  
- Multiplexers: `mux`  
- Serial-In Parallel-Out (SIPO) shift register  

### 2. **Source**  
This folder contains the main implementations of ECC algorithms. It is further divided into three subfolders:  

#### 2.1 **HammingCode (Initial Versions)**  
- Implements Hamming Code encoder and decoder using basic gate-level logic.  
- Uses components from the `Components` folder for modularity.  

#### 2.2 **HammingCode (Matrix Method)**  
- Implements Hamming Code encoder and decoder using the matrix method.  
- Includes:  
  - Standard Hamming Code  
  - Extended Hamming Code (adds an extra parity bit for enhanced error detection)  

#### 2.3 **HadamardCode**  
- Contains the implementation of Hadamard Code encoder and decoder.  
- Focuses on generating and decoding Hadamard codewords for robust error correction.  

---

## Features  
- **Modularity**: Reusable components designed to simplify and standardize the design of ECC systems.  
- **Multiple Encoding Methods**: Provides both gate-level and matrix-based approaches to implement Hamming Code.  
- **Support for Extended Hamming Code**: Adds a single parity bit for improved error detection.  
- **Hadamard Code Implementation**: A high-performance error correction technique for advanced applications.  

---

## Tools and Hardware  
- **Development Software**:  
  - Quartus Prime Lite  
  - ModelSim-Altera (for simulation)  

- **Hardware Platform**:  
  - DE10-Lite FPGA Board  

---

## How to Use  

### 1. Clone the Repository  
git clone <repository-url>  
cd ECC-ErrorCorrectionCodes

### 2. Navigate to the Desired Folder  
- For components: Navigate to the `Components` folder.  
- For specific ECC implementations, navigate to the respective subfolder under `Source`.  

### 3. Compile and Simulate  
- Open Quartus Prime Lite and create a new project.  
- Add the necessary VHDL files from the repository.  
- Compile the design and simulate its functionality using ModelSim-Altera.  

### 4. Run on Hardware  
- Synthesize the design to generate a `.sof` (SRAM Object File).  
- Use Quartus Programmer to upload the synthesized design onto the DE10-Lite FPGA board.  
- Test and verify the functionality on hardware using input switches and output LEDs.  

---

## Testing and Verification  
- **Simulation**:  
  - Each implementation has been simulated and verified using ModelSim-Altera.  
  - Testbenches are provided in the subfolders under `Source` to validate encoder and decoder functionality for Hamming Code and Hadamard Code.  

- **Hardware Testing**:  
  - Load the design onto the DE10-Lite board.  
  - Provide inputs using the board's switches and observe the outputs on LEDs or other peripherals to confirm proper operation.  

---

## Future Enhancements  
- Integration of BCH and Reed-Solomon Code for advanced ECC applications.  
- Performance optimization for high-speed encoding/decoding.  
- Addition of parameterized VHDL modules for scalability.  
- Detailed timing analysis and resource utilization benchmarks.  

---


