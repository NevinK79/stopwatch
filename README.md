# Programmable Stopwatch/Timer

RTL implementation of a four-mode programmable stopwatch/timer on the Digilent
Basys3 FPGA board.

## Overview

Displays time on the board's four 7-segment digits — the two MSD digits show
seconds, the two LSD digits show hundredths of a second (10ms resolution,
cycling 00-99 once per second). Two buttons (`startstop`, `reset`) and ten
switches (`sw[9:0]`) control mode selection, preset values, and run state.

## Modes (`sw[1:0]`)

| Mode | `sw[1:0]` | Behavior |
|---|---|---|
| 0 | `00` | Count up from `00.00` |
| 1 | `01` | Count down from `99.99` |
| 2 | `10` | Count up from a preset value (switches set the seconds digits) |
| 3 | `11` | Count down from a preset value (switches set the seconds digits) |

- **`startstop`** toggles run/pause. Each press flips between counting and
  holding at the current value.
- **`reset`** loads the mode's starting value immediately (no `startstop`
  press required) — `00.00` for mode 0, `99.99` for mode 1, or the
  switch-defined seconds value (with `.00` on the hundredths digits) for
  modes 2/3.
- Only the two seconds digits are ever externally loaded — the hundredths
  digits always start at `00` in preset modes.

## Switch mapping (`sw[9:0]`)

| Bits | Purpose |
|---|---|
| `sw[1:0]` | Mode select |
| `sw[5:2]` | Preset tens-of-seconds digit (modes 2/3) |
| `sw[9:6]` | Preset ones-of-seconds digit (modes 2/3) |

Values above `1001` (9) on either preset nibble are undefined and not
handled specially.

## Files

| File | Purpose |
|---|---|
| `main.v` | Top-level module — wires clock divider, FSM, and display driver to board I/O |
| `clkDiv.v` | Divides the 100MHz board clock down to `clk_10ms` and `clk_1ms` |
| `stopWatchFSM.v` | Core stopwatch logic: mode decode, BCD counters, load/count control, display refresh mux |
| `hexto7segment.v` | Combinational BCD-to-7-segment decoder |
| `stopWatch_cstr.xdc` | Basys3 pin constraints (matches Digilent's official master XDC) |
| `tb_stopWatch.v` | Testbench exercising all four modes, pause/resume, and reset |

### Controller/datapath split (optional alternate structure)

The core FSM logic can also be expressed as a separate controller and
datapath instead of one monolithic module:

- `controller.v` — pure FSM: decodes `startstop`/`reset`/`sw_mode` into three
  control signals (`load`, `count_en`, `count_up`)
- `datapath.v` — the BCD digit registers, increment/decrement/carry chain,
  load-value mux, and display refresh mux, driven entirely by the
  controller's signals
- `stopWatchFSM_split.v` — drop-in wrapper with the same port list as
  `stopWatchFSM.v`, instantiating `controller` + `datapath`

This split has been verified cycle-for-cycle equivalent to the monolithic
`stopWatchFSM.v` across all four modes, pause/resume, and mode changes.

## Display multiplexing

The board has one shared set of 7 segment lines (`sseg[6:0]`) driving all
four digits — only one digit can actually be lit at a time, so the design
cycles through them fast enough that persistence of vision makes all four
appear lit simultaneously:

- `clk_1ms` (derived from `clkDiv`, effectively a **1kHz** refresh clock)
  increments a 2-bit `select` counter every cycle.
- `select` picks which digit is "active" this cycle: it chooses that digit's
  BCD value to feed into `hexto7segment`, and sets `an[3:0]` (active-low,
  one-hot) to enable only that digit's anode transistor while the other
  three stay off.
- Since all four digits are cycled once every 4ms (4 × 1ms), the effective
  per-digit refresh rate is 250Hz — comfortably above the ~60Hz flicker
  threshold the eye can perceive.
- A digit that lights fewer segments (e.g. displaying "1" vs "8") will look
  visually dimmer purely because less LED area is glowing during its
  time-slice — the anode enable/duty-cycle itself is identical for every
  digit, this is not a hardware fault.

## Simulating

```bash
iverilog -o tb.vvp tb_stopWatch.v main.v clkDiv.v hexto7segment.v stopWatchFSM.v
vvp tb.vvp
```

Note: `clk_10ms` has a real ~10ms period through the actual `clkDiv`, so
reset/startstop pulses in the testbench must be held longer than one
`clk_10ms` period (10,000,000ns) to be sampled correctly, and a full test
run covers roughly 100-160ms of simulated time.

## Building for hardware

1. Open the project in Vivado, add all `.v` sources and `stopWatch_cstr.xdc`.
2. Run Synthesis → Implementation → Generate Bitstream.
3. Program the Basys3 via Hardware Manager.
4. Set `sw[1:0]` to the desired mode, press `reset`, then `startstop` to run.

## Known behavior / edge cases

- **Reset while running**: reloads the display's starting value immediately,
  but does **not** force the timer to stop — if it was running before reset,
  it keeps running afterward from the reloaded value.
- **Changing mode without pressing reset**: the current count continues
  under the newly selected mode's direction rather than reloading. Both
  this and reloading-on-mode-change are reasonable, valid behaviors — the
  design intentionally allows either.
