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

# Radiant Core Framework Documentation

Version: 1.0.0  
Type: Lua Proxy Framework (Growtopia Executor)

---

# 🧠 CORE ARCHITECTURE

Radiant menggunakan 4 layer utama:

1. **Command Layer** → register & routing command
2. **Controller Layer** → logic command
3. **Config Layer** → persistent settings
4. **Hook Layer** → packet & variant interceptor

---

# ⚙️ CONFIG SYSTEM (CORE)

## 📌 config

Main state storage semua fitur.

---

## 🔁 toggle(tbl, key)

Toggle value 0 ↔ 1 dan auto-save config.

### Usage:
```lua
toggle(config.spin, "reme")
