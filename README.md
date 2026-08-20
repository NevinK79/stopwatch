# Programmable Stopwatch/Timer

RTL implementation of a four-mode programmable stopwatch/timer on the
Digilent Basys3 FPGA board.

## Demo
[![Watch the demo](https://img.youtube.com/vi/Rkqap1vFbTs/0.jpg)](https://youtu.be/Rkqap1vFbTs)

## Overview

Time is displayed on the board's four 7-segment digits: the two
most-significant digits show seconds, and the two least-significant digits
show hundredths of a second (10 ms resolution, cycling 00–99 once per
second). Two buttons (`startstop`, `reset`) and ten switches (`sw[9:0]`)
control mode selection, preset values, and run state.

## Modes (`sw_mode` = `sw[1:0]`)

| Mode | `sw[1:0]` | Behavior                                        |
|------|-----------|--------------------------------------------------|
| 0    | `00`      | Count **up** from `00.00`                        |
| 1    | `01`      | Count **down** from `99.99`                       |
| 2    | `10`      | Count **up** from a preset seconds value          |
| 3    | `11`      | Count **down** from a preset seconds value        |

- **`startstop`** is edge-triggered: each press toggles between running and
  holding at the current value.
- **`reset`** immediately loads the mode's starting value — `00.00` for mode
  0, `99.99` for mode 1, or `{inTens, inOnes}.00` for modes 2/3 — regardless
  of `startstop` state.
- Counting saturates rather than wraps: mode 0/2 stop incrementing at
  `99.99`, mode 1/3 stop decrementing at `00.00`.

## Module reference

### `stopWatchFSM.v`
Core logic. Holds four BCD digit registers (`s_2`, `s`, `ms`, `ms_2`), a
`start` flip-flop toggled on the rising edge of `startstop`, and a 2-bit
`select` counter that multiplexes one digit at a time onto the shared
`sseg`/`an` lines.

| Port | Direction | Description |
|------|-----------|--------------|
| `clk_10ms` | in | Tick used to advance/hold the digit counters |
| `clk_1ms`  | in | Tick used to advance the digit-select multiplexer |
| `reset`    | in | Loads the mode's starting value |
| `startstop`| in | Toggles run/pause on each press |
| `inTens`, `inOnes` | in | Preset seconds digits (modes 2/3), typically driven from switches |
| `sw_mode`  | in | Mode select, `sw[1:0]` |
| `an[3:0]`  | out | Active-low, one-hot digit enable |
| `sseg[7:0]`| out | 7-segment cathodes (`[6:0]`) + decimal point (`[7]`) |

### `clkDiv.v`
Divides a 100 MHz board clock into two slower ticks used by the FSM: a
`clk_10ms` (10 ms period) counter tick and a `clk_1ms` (1 ms period) display
refresh tick.

### `hexto7segment.v`
Combinational BCD-to-7-segment decoder. Takes a 4-bit BCD digit plus a
`decimal` bit and produces the 8-bit `sseg` pattern for the digit currently
selected by the FSM.

### `main.v`
Top-level module. Instantiates `clkDiv` and `stopWatchFSM`, wiring
`clk_10ms`/`clk_1ms` between them and splitting the board's `sw[9:0]` input
as `sw[1:0]` → `sw_mode`, `sw[5:2]` → `inOnes`, `sw[9:6]` → `inTens`. This is
the module to set as top in Vivado when building a bitstream.

| Port | Direction | Description |
|------|-----------|--------------|
| `clk` | in | 100 MHz board clock |
| `reset` | in | Loads the mode's starting value |
| `startstop` | in | Toggles run/pause on each press |
| `sw[9:0]` | in | Mode select, preset tens, and preset ones digits |
| `sseg[7:0]` | out | 7-segment cathodes + decimal point |
| `an[3:0]` | out | Active-low, one-hot digit enable |

## Display multiplexing

The board has a single shared set of 7-segment lines driving all four
digits, so only one digit is actually lit at a time. `clk_1ms` increments a
2-bit `select` counter that picks which digit's BCD value feeds
`hexto7segment` and which single bit of `an[3:0]` is pulled low. Cycling
through all four digits every 4 ms gives an effective per-digit refresh rate
of 250 Hz, well above the ~60 Hz flicker threshold.

## Pin constraints (`stopWatch_cstr.xdc`)

Maps the design's top-level ports to the Basys3's `clk`, `sw[9:0]`,
`sseg[7:0]`, `an[3:0]`, `startstop`, and `reset` pins, based on Digilent's
official Basys3 master XDC.

## Building for hardware

### Option 1: Program the prebuilt bitstream
`main.bit` is a prebuilt bitstream for the Basys3. Open Vivado's Hardware
Manager, connect to the board, and program the device directly with this
file — no synthesis required.

### Option 2: Build from source
1. In Vivado, add all `.v` sources (`clkDiv.v`, `hexto7segment.v`,
   `stopWatchFSM.v`, `main.v`) plus `stopWatch_cstr.xdc`, and set `main` as
   the top-level module.
2. Run Synthesis → Implementation → Generate Bitstream.
3. Program the Basys3 via Hardware Manager.
4. Set the mode switches, press `reset`, then `startstop` to run.

## Known behavior

- **Reset while running** reloads the display immediately but does not stop
  the count — if it was running before reset, it keeps running afterward
  from the reloaded value.
- **Changing mode without pressing reset** lets the current count continue
  in the newly selected direction rather than reloading.
- **7-segment decoder input range** — `hexto7segment` accepts the full 4-bit
  input range (0–F), not just BCD digits, but the FSM only ever drives it
  with values 0–9. Inputs above 9 are supported by the hardware but aren't
  expected to occur during normal operation.
