<img width="1600" height="900" alt="waveform__prng" src="https://github.com/user-attachments/assets/1c76a708-ec85-4f76-9898-e3cadfa6a3fc" />
# 🔐 8-bit Stream Cipher Encryptor/Decryptor

A lightweight hardware encryption/decryption system implemented in Verilog HDL, designed and verified using **Quartus Prime Lite** and **ModelSim**.

---

## Overview

This project implements an 8-bit stream cipher based on a **Pseudo-Random Number Generator (PRNG)** built from a **Linear Feedback Shift Register (LFSR)**. The PRNG generates a dynamic keystream, which is XOR-ed with input data to perform symmetric encryption and decryption — same logic, same seed, works both ways.

---

## Architecture

```
seed_in ──►┌─────────┐  keystream  ┌──────────────┐
           │  PRNG   │────────────►│  top_encrypt │──► data_out
           │ (LFSR)  │             │  (XOR logic) │
           └─────────┘             └──────────────┘
                ▲                         ▲
           load_seed                  data_in
```

### Modules

| Module | Description |
|---|---|
| `prng.v` | 8-bit LFSR-based PRNG with configurable seed; feedback polynomial: x⁸ + x⁶ + x⁵ + x⁴ + 1 |
| `top_encrypt.v` | Top-level module — instantiates PRNG, delays signals by one clock, XORs keystream with data |
| `top_encrypt_golden.v` | Golden reference model used for self-checking verification |
| `tb_encrypt.v` | Self-checking testbench — encrypts ASCII text and hex data, validates DUT vs reference |

---

## How It Works

1. **Reset** — PRNG loads default seed `0xCD`
2. **Optional seed load** — Override via `load_seed` + `seed_in`
3. **Encryption** — Assert `encrypt_en`; PRNG shifts one cycle, `data_out = prng ^ data_in` (registered, 1-cycle latency)
4. **Decryption** — Feed the encrypted bytes back with the same seed — XOR is its own inverse

---

## Simulation & Verification

Testbench covers two scenarios:

- **Plaintext encryption** — ASCII string `"Red apple."` encrypted byte-by-byte
- **Decryption validation** — Encrypted ciphertext re-XORed with same PRNG sequence to recover original data
- **Self-checking** — DUT output compared against golden model every cycle; pass/fail logged with counts

All 30 test vectors passed with `error_count = 0`.

Verified in **ModelSim** — waveforms confirm correct clock-edge alignment, seed loading, encryption enable, and matching `data_out` vs `data_out_ref`.

## Tools Used

- **Quartus Prime Lite** — RTL synthesis
- **ModelSim (Intel FPGA Starter Edition)** — Functional simulation & waveform analysis
- **Verilog HDL** — RTL design language

---

## Key Concepts Demonstrated

- LFSR-based PRNG design
- Stream cipher principles (XOR keystream)
- RTL-level pipelining (1-cycle delay register)
- Self-checking testbench methodology
- Waveform-based functional verification

---

## File Structure

```
├── prng.v                  # PRNG (LFSR) module
├── top_encrypt.v           # Top-level encrypt/decrypt module
├── top_encrypt_golden.v    # Golden reference model
├── tb_encrypt.v            # Self-checking testbench
└── tb_encrypt_v.bak        # Testbench backup
```

---
