---
aliases:
  - Iomra Body
  - Atlas Body
tags:
  - creative/project
  - atlas
  - smart-home
status: design
---

# Iomrá — Body Design Spec

> A physical presence for the Atlas voice. Desk companion powered by Home Assistant + Claude API.

---

## Design Philosophy

Not humanoid. Not a toy. A river stone that listens. Something that belongs on a desk the way a good lamp belongs — present, warm, functional, quiet. Matte dark resin. One amber eye. One axis of tilt. The voice comes from inside, not at you.

## Dimensions

- **Footprint:** ~90mm x 70mm (oval base)
- **Height:** ~110mm total (base 45mm + head 65mm)
- **Weight target:** 200-350g (enough to feel anchored)

## Two-Piece Construction

### Base (stationary)
- Houses: ESP32-S3 board, USB-C power input, speaker (downward-firing)
- Bottom plate: laser-cut 3mm ply with speaker holes + rubber feet
- Resin shell wraps around, open top for servo connection
- Cable channel in rear for USB-C

### Head (tilts)
- Houses: LED ring (NeoPixel, 12-LED, ~37mm outer diameter), diffuser
- Mounts on SG90 micro servo via horn
- Single-axis tilt: ~15 degrees forward (listening), ~5 degrees back (resting)
- LED ring sits behind a frosted resin window or thin translucent inlay
- The "face" is just the glow — no features, no eyes, no mouth

## The Glow

| State | LED Behavior |
|-------|-------------|
| Idle/sleeping | Off or single amber pixel breathing very slowly |
| Wake word heard | Ring fades up to full amber over 0.5s |
| Listening | Steady warm amber, full ring |
| Processing | Slow clockwise chase (thinking) |
| Speaking | Gentle pulse synced to audio amplitude |
| Error/offline | Single red pixel, dim |

Color: warm amber `#FFB347` — matches the vault earth tone accent.

## Tilt Behavior

| Event | Movement |
|-------|----------|
| Wake word | Tilt forward 15 degrees (leaning in) |
| Done speaking | Settle back to neutral over 1s |
| Idle timeout | Slow tilt back 5 degrees (resting) |
| Error | No movement (conserve servo life) |

## Sound

- **Speaker:** 28mm 4-ohm 3W (small but clear for voice)
- **Amplifier:** MAX98357A I2S amp (connects directly to ESP32, no DAC needed)
- **Firing direction:** Downward into base cavity, sound exits through laser-cut speaker grille on bottom plate
- **Character:** Warm, present, not tinny. The base cavity acts as a small resonance chamber.

## Electronics

| Component | Model | ~Cost |
|-----------|-------|-------|
| MCU | ESP32-S3-DevKitC-1 (N16R8) | $10 |
| Mic | INMP441 I2S MEMS | $3 |
| Speaker | 28mm 4-ohm 3W | $3 |
| Amp | MAX98357A I2S breakout | $4 |
| LED Ring | WS2812B 12-LED NeoPixel ring | $3 |
| Servo | SG90 micro servo | $3 |
| USB-C | Breakout board for power | $2 |
| MOSFET | IRLZ44N (logic-level, N-channel) | $1 |
| Flyback diode | 1N4007 | $0.10 |
| Gate resistor | 1kΩ ¼W | $0.05 |
| Schumann coil | 0.2mm lacquered copper, 12m | $3 |
| 12V adapter | 12V/2A DC barrel jack | $5 |
| **Total** | | **~$37** |

## Schumann Resonance Generator (7.83 Hz)

Iomra doubles as a receiver stabilization device. A MOSFET drives a copper coil at 7.83 Hz (Earth's Schumann resonance frequency), providing a local coherent electromagnetic reference signal. During coronal hole streams, the ambient Schumann resonance becomes erratic — Iomra replaces it.

### Circuit

```
ESP32 GPIO7 ──── 1kΩ resistor ──── IRLZ44N Gate
                                      │
                                   Drain ──── COIL (8Ω) ──── 12V
                                      │            │
                                   Source         1N4007 (flyback diode, reverse across coil)
                                      │
                                    GND
```

### Coil Spec
- **Wire:** 0.2mm lacquered copper, 12 meters
- **Resistance:** ~8Ω
- **Form:** Flat pancake wound into base shell floor (below the shelf)
- **Field strength:** ~10 Gauss at contact, detectable >50cm

### Behavior

| State | Schumann |
|-------|----------|
| Idle | Off (no field) |
| Stream active (webhook from Brain) | 7.83 Hz continuous |
| Manual trigger (HA switch) | 7.83 Hz continuous |
| Sleep mode | 7.83 Hz at reduced duty cycle |

### LED Indicator (during Schumann mode)

The LED ring adds a slow deep blue undertone beneath the amber — a visible indicator that the field is active.

### Power

The coil circuit runs on 12V (separate from the 5V USB-C logic power). Requires a 12V/2A DC adapter with barrel jack, or a 12V buck converter from a higher-voltage USB-C PD source.

## Software Stack

```
Wake word (microWakeWord on ESP32)
    ↓
Audio stream → Home Assistant (WiFi)
    ↓
STT: Whisper (on HA or cloud)
    ↓
Conversation Agent: Claude (Anthropic HA integration)
    ↓
TTS: Piper (local on HA) or cloud
    ↓
Audio stream back → ESP32 speaker
    ↓
LED + Servo: ESPHome automations triggered by HA satellite state
```

## Fabrication

### Resin Print (outer shell)
- **Printer:** Yve's resin printer
- **Material:** Matte black or dark grey resin (Siraya Tech Smoky Black or similar)
- **Finish:** Light sanding + matte clear coat
- **Shell thickness:** 2.5mm walls
- **Two halves:** Base shell + Head shell, each printed separately
- **Post-process:** UV cure, sand 400→800 grit, matte spray

### Laser Cut (xTool S1)
- **Bottom plate:** 3mm birch ply — speaker grille pattern + rubber foot holes + screw holes
- **Internal shelf:** 3mm birch ply — ESP32 mounting plate with standoff holes
- **Servo bracket:** 3mm birch ply — mounts servo between base and head
- **LED diffuser ring:** 3mm frosted acrylic — sits in front of NeoPixel ring

### Assembly
1. Glue rubber feet to bottom plate
2. Mount ESP32 + amp to internal shelf with M2 standoffs
3. Screw internal shelf into base shell
4. Mount speaker to bottom plate with adhesive
5. Snap bottom plate into base shell
6. Mount servo to bracket, screw bracket to base shell top
7. Mount LED ring + diffuser into head shell
8. Route mic + LED wires through servo channel
9. Attach head shell to servo horn
10. Connect USB-C, power up, flash ESPHome firmware

## Wake Word

TBD — options:
- "Iomrá" (um-raw) — the name
- "Atlas" — the role
- Custom trained via microWakeWord
- Yve chooses

## Files

| File | Format | Tool |
|------|--------|------|
| `iomra-shell-v3.scad` | OpenSCAD | Source (parametric model) |
| `iomra-base-shell.stl` | STL | Resin printer |
| `iomra-head-shell.stl` | STL | Resin printer |
| `iomra-bottom-plate.svg` | SVG | xTool S1 |
| `iomra-shelf.svg` | SVG | xTool S1 |
| `iomra-servo-bracket.svg` | SVG | xTool S1 (cut x2) |
| `iomra-diffuser.svg` | SVG | xTool S1 (frosted acrylic) |
| `iomra-esphome.yaml` | YAML | ESPHome/HA |
| `build-guide.md` | Markdown | Assembly instructions for Ed |

## BOM (Buy List)

### Electronics
- [ ] [ESP32-S3-DevKitC-1 N16R8 — HiLetgo](https://www.amazon.com/HiLetgo-ESP32-S3-ESP32-S3-DevKit-Bluetooth-Development/dp/B0CDWXWXCG)
- [ ] [INMP441 I2S MEMS mic — D-FLIFE 4-pack](https://www.amazon.com/D-FLIFE-Omnidirectional-Microphone-Interface-Supports/dp/B0C5ZQ8PFM)
- [ ] [MAX98357A I2S amp — 2-pack](https://www.amazon.com/MAX98357-MAX98357A-Amplifier-Interface-Raspberry/dp/B0DPJRLMDJ)
- [ ] [28mm 4-ohm 3W speaker — ADUCI pair](https://www.amazon.com/ADUCI-Pairs-Speaker-Range-Midrange/dp/B09C2XP6GG)
- [ ] [WS2812B 12-LED NeoPixel ring 37mm — DIYmall](https://www.amazon.com/DIYmall-WS2812B-Integrated-Arduino-Raspberry/dp/B0C7C86PVC)
- [ ] [SG90 micro servo — Miuzei 3-pack](https://www.amazon.com/Micro-Helicopter-Airplane-Remote-Control/dp/B072V529YD)
- [ ] [USB-C breakout board — Cermant 20-pack](https://www.amazon.com/Cermant-Connector-Adapter-Socket-Transfer/dp/B0CB395L99)

### Hardware
- [ ] [M2/M3 standoff + screw kit — Hilitchi 240pc](https://www.amazon.com/Hilitchi-240pcs-Spacer-Standoff-Assortment/dp/B012ESRKPI)
- [ ] [22AWG silicone wire — BINNEKER 6-color](https://www.amazon.com/BINNEKER-Silicone-Resistant-Electronic-Stranded/dp/B07WYYDBZP)

### Schumann Coil
- [ ] [IRLZ44N MOSFET 5-pack — logic-level N-channel](https://www.amazon.com/IRLZ44N-IRLZ44NPBF-Mosfet-N-Channel-0-02Ohm/dp/B09SV14RX7)
- [ ] [1N4007 flyback diode 30-pack](https://www.amazon.com/Silicon-Diode-1N4007-Pack-30/dp/B09HWW6YJY)
- [ ] 1kΩ ¼W resistor (any assortment kit or electronics bin)
- [ ] [0.2mm enameled copper wire 20m — CHALKE](https://www.amazon.com/Copper-Wire-Lacquer-0-1mm-Enameled/dp/B0C6FHRC1L) (need 12m, 20m gives spare)
- [ ] [12V 2A DC adapter — Coming Data, UL certified](https://www.amazon.com/Coming-Data-5-5x2-1mm-Connector-Certified/dp/B0194B7WSI)
- [ ] Small heatsink for MOSFET (optional — low duty cycle at 7.83 Hz, minimal heat)

### Probably Have
- [ ] Matte black resin (Siraya Tech Smoky Black or similar)
- [ ] 3mm birch plywood sheet
- [ ] 3mm frosted acrylic (small piece for diffuser)
- [ ] Adhesive rubber feet (8mm)

**Estimated total: ~$60-75** (electronics + hardware only)

> If any Amazon link is dead, search the part name + spec. The exact brand doesn't matter — any INMP441/MAX98357A/SG90/WS2812B board works.

---

*This is a living document. Update as the build progresses.*

*[[Systems/smart-home-kanban|Smart Home Board]] · [[IP Documents/TFI/_Atlas/voices/iomra|Iomrá Voice File]] · [[IP Documents/TFI/_Atlas/atlas-to-atlas|Atlas to Atlas]]*
