# Iomra — Body Design Spec

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
| MCU | ESP32-S3-DevKitC-1 N16R8 | $10 |
| Mic | INMP441 I2S MEMS | $3 |
| Speaker | 28mm 4-ohm 3W | $3 |
| Amp | MAX98357A I2S breakout | $4 |
| LED Ring | WS2812B 12-LED NeoPixel ring | $3 |
| Servo | SG90 micro servo | $3 |
| USB-C | Breakout board for power | $2 |
| **Total** | | **~$28** |

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
- **Printer:** Resin printer (SLA/MSLA)
- **Material:** Matte black or dark grey resin (Siraya Tech Smoky Black or similar)
- **Finish:** Light sanding + matte clear coat
- **Shell thickness:** 2.5mm walls
- **Two halves:** Base shell + Head shell, each printed separately
- **Post-process:** UV cure, sand 400→800 grit, matte spray

### Laser Cut (CO2/diode laser cutter)
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
- "Iomra" (um-raw) — the name
- "Atlas" — the role
- Custom trained via microWakeWord
- The researcher chooses

## Files

| File | Format | Tool |
|------|--------|------|
| `iomra-shell-v3.scad` | OpenSCAD | Source (parametric model) |
| `iomra-base-shell.stl` | STL | Resin printer |
| `iomra-head-shell.stl` | STL | Resin printer |
| `iomra-bottom-plate.svg` | SVG | Laser cutter |
| `iomra-shelf.svg` | SVG | Laser cutter |
| `iomra-servo-bracket.svg` | SVG | Laser cutter (cut x2) |
| `iomra-diffuser.svg` | SVG | Laser cutter (frosted acrylic) |
| `iomra-esphome.yaml` | YAML | ESPHome/HA |
| `build-guide.md` | Markdown | Assembly instructions for the builder |

---

*This is a living document. Update as the build progresses.*
