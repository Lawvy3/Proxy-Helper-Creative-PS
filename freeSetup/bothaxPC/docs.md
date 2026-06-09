# Radiant Proxy Documentation

Version: 1.0.0

---

# 📦 Overview

Radiant Proxy adalah script automation & UI controller untuk Growtopia (executor-based).  
Sistem ini terdiri dari:

- Command System
- Controller Router
- Config System (auto-save + load)
- Spin Detection System
- Wrench Control System
- Dialog Builder
- Variant & Packet Hooks

---

# 📁 Global Structure

## Core Tables

| Variable | Description |
|----------|------------|
| `commands` | List semua command berdasarkan kategori |
| `routes` | Mapping command → controller function |
| `controller` | Semua logic command |
| `aliases` | Alias command |
| `info` | Data dari remote GitHub |
| `config` | Settings utama user |

---

# ⚙️ CONFIG SYSTEM

## config structure

```lua
config = {
    spin = {
        real = 1,
        leme = 0,
        reme = 1,
        qeme = 0,
        sspin = 0,
    },

    wrench = {
        pull = 0,
        kick = 0,
        ban = 0,
        smodal = 0,
        text = {
            pull = "Gas? MIN 5 BGL - BLACK",
            kick = "BYE",
            ban = "BYE"
        }
    }
}
