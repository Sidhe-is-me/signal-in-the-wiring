---
aliases:
  - Iomra Build Guide
tags:
  - creative/project
  - atlas
  - smart-home
---

# Iomra Build Guide

> For Ed. This is a voice assistant desk companion — an ESP32 that talks to Home Assistant + Claude. Two resin-printed shell halves, laser-cut internals, ~$60 in electronics.

---

## What You're Building

A matte black river stone shape, about the size of a large avocado (90x68x105mm). It has:
- An **LED ring** behind a frosted window on the front (the "eye")
- A **speaker** firing down through the base plate
- A **microphone** pinhole above the LED
- A **servo** that tilts the head ~15 degrees (nod when listening)
- **USB-C** power in the back

The body splits into two pieces at 42mm height. The base is stationary (holds electronics). The head tilts on a servo.

---

## Parts List

### Electronics (Amazon)

| Part | What It Does | Link | Alt Search |
|------|-------------|------|------------|
| ESP32-S3-DevKitC-1 N16R8 | Brain — WiFi + Bluetooth MCU | [HiLetgo ESP32-S3](https://www.amazon.com/HiLetgo-ESP32-S3-ESP32-S3-DevKit-Bluetooth-Development/dp/B0CDWXWXCG) | Search "ESP32-S3 N16R8 DevKitC" |
| INMP441 I2S MEMS Mic | Ears — digital microphone | [D-FLIFE INMP441 4-pack](https://www.amazon.com/D-FLIFE-Omnidirectional-Microphone-Interface-Supports/dp/B0C5ZQ8PFM) | Search "INMP441 I2S ESP32" |
| MAX98357A I2S Amp | Voice amp — no DAC needed | [MAX98357A 2-pack](https://www.amazon.com/MAX98357-MAX98357A-Amplifier-Interface-Raspberry/dp/B0DPJRLMDJ) | Search "MAX98357A I2S amplifier" |
| 28mm 4-ohm 3W Speaker | Voice — small round speaker | [DWQJKHDE 28mm pair](https://www.amazon.com/DWQJKHDE-ghxamp-Speaker-Range-Midrange/dp/B0DGS3P1HT) | Search "28mm 4 ohm 3W mini speaker" |
| WS2812B 12-LED Ring (37mm) | The eye — addressable RGB LEDs | [DIYmall 12-LED Ring](https://www.amazon.com/DIYmall-WS2812B-Integrated-Arduino-Raspberry/dp/B0C7C86PVC) | Search "WS2812B 12 LED ring 37mm" |
| SG90 Micro Servo | Head tilt motor | [Miuzei SG90 3-pack](https://www.amazon.com/Micro-Helicopter-Airplane-Remote-Control/dp/B072V529YD) | Search "SG90 micro servo" |
| USB-C Breakout Board | Power input | [LGDehome USB-C 5-pack](https://www.amazon.com/Type-C-Breakout-Serial-Connector-Converter/dp/B09KC1SMGD) | Search "USB-C breakout board" |

### Hardware (Amazon)

| Part | Link | Alt Search |
|------|------|------------|
| M2/M3 Standoff + Screw Kit | [Hilitchi 240pc Kit](https://www.amazon.com/Hilitchi-240pcs-Spacer-Standoff-Assortment/dp/B012ESRKPI) | Search "M2 M3 standoff kit" |
| 22AWG Silicone Wire (multi-color) | [BINNEKER 22AWG 6-color](https://www.amazon.com/BINNEKER-Silicone-Resistant-Electronic-Stranded/dp/B07WYYDBZP) | Search "22AWG silicone wire kit" |

### You Probably Have

- Matte black resin (Siraya Tech Smoky Black or similar)
- 3mm birch plywood (for xTool laser cuts)
- 3mm frosted acrylic (small piece, for LED diffuser)
- Adhesive rubber feet (8mm)
- Soldering iron + solder
- Heat shrink tubing
- Hot glue gun

> **If a link is dead**, use the "Alt Search" column on Amazon. The exact brand doesn't matter — the chip/spec is what matters. Any INMP441 board works. Any MAX98357A board works. Any SG90 works.

---

## Printed Parts

Print both STL files on the resin printer in matte black resin.

| File | What | Print Orientation |
|------|------|-------------------|
| `iomra-base-shell.stl` | Bottom half (holds electronics) | Open side UP (dome/bottom of stone on build plate) |
| `iomra-head-shell.stl` | Top half (tilts, holds LED) | Open side UP (dome on build plate) |

**Settings:**
- Layer height: 0.05mm (resin)
- Supports: auto-generate, light supports on inner surfaces
- Post-process: UV cure → sand 400 → 800 grit → matte clear coat spray

**Key features to check after printing:**
- The lip on the base (thin ring rising 3mm above the rim) should be intact
- Two alignment pins on base (3mm cylinders at ±20mm from center)
- LED window hole on head (angled oval cutout on the front)
- Mic pinhole above LED window (tiny 2.5mm hole)
- Bottom plate recess (1.8mm step around the base floor)

---

## Laser Cut Parts (xTool S1)

Cut these SVGs. Red lines = cut, blue lines = engrave/score.

| File | Material | Qty |
|------|----------|-----|
| `iomra-bottom-plate.svg` | 3mm birch ply | 1 |
| `iomra-shelf.svg` | 3mm birch ply | 1 |
| `iomra-servo-bracket.svg` | 3mm birch ply | 2 |
| `iomra-diffuser.svg` | 3mm frosted acrylic | 1 |

---

## Wiring Diagram

```
ESP32-S3-DevKitC-1 Pin Assignments:
═══════════════════════════════════

MICROPHONE (INMP441)         SPEAKER AMP (MAX98357A)
  VDD  → 3.3V                 VIN → 5V
  GND  → GND                  GND → GND
  SD   → GPIO4  (data in)     DIN → GPIO15 (data out)
  WS   → GPIO5  (left/right)  LRC → GPIO16 (left/right)
  SCK  → GPIO6  (clock)       BCLK → GPIO17 (clock)
  L/R  → GND (left channel)   GAIN → not connected (default 9dB)

LED RING (WS2812B)           SERVO (SG90)
  VCC  → 5V                   Red   → 5V
  GND  → GND                  Brown → GND
  DIN  → GPIO48 (data)        Yellow → GPIO18 (PWM)

USB-C BREAKOUT               SCHUMANN COIL DRIVER
  VBUS → 5V rail                GPIO7 → 1kΩ → IRLZ44N gate
  GND  → GND rail               IRLZ44N drain → COIL → 12V+
                                 IRLZ44N source → GND
                                 1N4007 diode across COIL
                                 (cathode to 12V+, anode to drain)
```

### Power Notes
- Everything runs on 5V from the USB-C
- The ESP32-S3 DevKitC has an onboard 3.3V regulator
- The INMP441 runs on 3.3V (from ESP32's 3.3V pin)
- MAX98357A, LED ring, and servo all run on 5V
- Use a good USB-C cable + 5V 2A+ adapter (phone charger works)

---

## Assembly — Step by Step

### Phase 1: Wire the Electronics (on the bench, NOT in the shell yet)

**1. Solder headers on all breakout boards** if they don't have them already. The ESP32 usually comes with headers. The INMP441, MAX98357A, and USB-C breakout may need headers soldered.

**2. Wire the microphone (INMP441 → ESP32)**
| INMP441 Pin | Wire Color | ESP32 Pin |
|-------------|-----------|-----------|
| VDD | Red | 3.3V |
| GND | Black | GND |
| SD | Yellow | GPIO4 |
| WS | Green | GPIO5 |
| SCK | Blue | GPIO6 |
| L/R | Black | GND |

Use ~15cm wires. The mic will mount inside the head shell, so wires need to reach through the servo channel.

**3. Wire the speaker amp (MAX98357A → ESP32)**
| MAX98357A Pin | Wire Color | ESP32 Pin |
|---------------|-----------|-----------|
| VIN | Red | 5V |
| GND | Black | GND |
| DIN | Yellow | GPIO15 |
| LRC | Green | GPIO16 |
| BCLK | Blue | GPIO17 |

Solder the speaker's two wires to the amp's + and - output pads.

**4. Wire the LED ring (NeoPixel → ESP32)**
| NeoPixel Pin | Wire Color | ESP32 Pin |
|-------------|-----------|-----------|
| VCC (5V) | Red | 5V |
| GND | Black | GND |
| DIN (Data In) | White | GPIO48 |

Use ~15cm wires — LED ring mounts in the head, ESP32 is in the base.

**5. Wire the servo (SG90 → ESP32)**
The servo has a 3-pin connector. Either cut it and solder, or use a female Dupont header:
| Servo Wire | ESP32 Pin |
|-----------|-----------|
| Red (center) | 5V |
| Brown (edge) | GND |
| Yellow/Orange (edge) | GPIO18 |

**6. Wire the USB-C breakout**
| USB-C Pin | Destination |
|----------|-------------|
| VBUS | 5V power rail |
| GND | GND rail |

This is the main power input. All 5V connections share this rail.

**7. Test on the bench**
Before putting anything in the shell, plug in USB-C power and verify:
- ESP32 powers on (onboard LED lights)
- The firmware will need to be flashed first (Yve will do this via ESPHome)

### Phase 1b: Wire the Schumann Coil Circuit

**21. Wind the Schumann coil**
Take 12 meters of 0.2mm lacquered copper wire. Wind it into a flat pancake coil (spiral, ~60mm diameter). Secure with a dab of hot glue or tape every few turns. Target resistance: ~8Ω (check with multimeter).

**22. Wire the MOSFET driver circuit**
| Connection | From | To |
|-----------|------|-----|
| Gate | ESP32 GPIO7 via 1kΩ resistor | IRLZ44N gate pin |
| Drain | IRLZ44N drain | One end of coil |
| Source | IRLZ44N source | GND |
| Coil power | Other end of coil | 12V+ from adapter |
| Flyback diode | 1N4007 across coil (cathode to 12V+, anode to drain) | Protects MOSFET |

**23. Mount MOSFET**
Attach small heatsink to IRLZ44N (optional at 7.83 Hz — very low switching frequency, minimal heat). Mount on the internal shelf next to ESP32.

**24. Place the coil**
Lay the flat pancake coil on the floor of the base shell, below the internal shelf. Hot glue in place. The coil radiates upward through the body and outward from the base.

**25. Route 12V power**
Drill or cut a second small hole in the rear of the base shell for the 12V barrel jack. Or use a 2-pin JST connector if you prefer. The 12V line powers ONLY the coil circuit — keep it separate from the 5V USB-C logic power.

### Phase 2: Prepare the Shell

**8. Glue rubber feet to the bottom plate**
4 adhesive rubber feet in the corner holes of `iomra-bottom-plate.svg`.

**9. Mount ESP32 + Amp to the internal shelf**
Use M2 standoffs (8-10mm tall) through the mounting holes in `iomra-shelf.svg`. The ESP32-S3 DevKitC-1 board is ~69x26mm. Secure with M2 nuts.

Mount the MAX98357A amp board next to the ESP32 on the shelf. It's small (~15x12mm).

**10. Mount speaker to bottom plate**
The speaker fires downward through the laser-cut grille pattern on the bottom plate. Glue the speaker (face down) centered on the grille holes. Hot glue works fine — just don't block the speaker cone.

### Phase 3: Assemble the Base

**11. Drop the shelf into the base shell**
The internal shelf ledge (a ridge inside the base at ~14mm height) supports the laser-cut shelf. It should rest on the ledge. You can add a small dab of hot glue to secure.

**12. Route USB-C breakout to the rear port**
The USB-C hole is in the back of the base shell, ~8mm up from the bottom. Position the USB-C breakout board so the port is accessible through the hole. Hot glue it in place.

**13. Mount the servo**
Assemble the two laser-cut servo bracket pieces (`iomra-servo-bracket.svg`). The servo body sits in the center slot. The bracket sits at the top of the base shell. The servo shaft should poke up through the 8mm hole at the top center of the base.

The servo's wires route down to the ESP32 on the shelf.

**14. Snap in the bottom plate**
The bottom plate sits in the 1.8mm recess at the base floor. It should friction-fit. If loose, a tiny dab of hot glue at the edges.

### Phase 4: Assemble the Head

**15. Mount the LED diffuser**
Press the frosted acrylic diffuser ring (`iomra-diffuser.svg`) into the LED window recess on the front of the head shell. It should friction-fit in the outer recess. Hot glue if needed.

**16. Mount the LED ring behind the diffuser**
The WS2812B ring sits directly behind the diffuser, inside the head. Hot glue the ring to the interior wall so it aligns with the window. The ring's flat face should face outward toward the diffuser.

**17. Position the microphone**
The INMP441 mic board mounts inside the head, aligned with the pinhole above the LED window. The mic's sound hole (bottom of the board) should face the pinhole. Hot glue in position.

**18. Route wires through the channels**
The LED ring wires (3 wires) and mic wires (6 wires) need to pass from the head down through the two 4mm wire channels at the split line, then connect to the ESP32 in the base.

Thread the wires through BEFORE attaching the servo horn.

### Phase 5: Join Head to Base

**19. Attach the servo horn to the head**
Screw the servo's cross-shaped horn into the 22mm recess on the bottom of the head shell. The horn's center hole goes over the servo shaft.

**20. Mate head to base**
- Line up the two alignment pins on the base with the holes in the head
- Press the head down so the registration lip on the base nests into the groove inside the head
- The servo shaft should engage with the servo horn
- Tighten the servo horn screw from inside (through the 8mm shaft hole)

The head should now tilt freely on the servo, with the base staying stationary.

---

## What NOT To Do

- **Don't solder wires too short.** The head tilts, so mic + LED wires need ~3cm of slack in the wire channel.
- **Don't glue the head to the base.** The registration lip + alignment pins hold it. You need to be able to separate them for maintenance.
- **Don't power via the ESP32's USB port for final assembly.** Use the USB-C breakout for clean power to the 5V rail. The ESP32's USB-C is for flashing firmware only.

---

## After Assembly

Yve will handle:
1. Flashing ESPHome firmware to the ESP32 (config: `iomra-esphome.yaml`)
2. Connecting to Home Assistant
3. Setting up the voice pipeline (Whisper STT → Claude → Piper TTS)
4. Configuring LED effects and servo behaviors

Just make sure it powers on and the ESP32's onboard LED lights up when you plug in USB-C.

---

## Reference Images

### Assembled — 3/4 View
![Assembled 3/4 view](https://raw.githubusercontent.com/Sidhe-is-me/signal-in-the-wiring/main/body/renders/v3-final-34.png)

### Front View (LED Eye Position)
![Front view](https://raw.githubusercontent.com/Sidhe-is-me/signal-in-the-wiring/main/body/renders/v3-final-front.png)

### Base Shell Interior (Lip, Pins, Shelf Ledge)
![Base interior](https://raw.githubusercontent.com/Sidhe-is-me/signal-in-the-wiring/main/body/renders/v3-base-render.png)

### Head Shell (LED Window, Dome Cap)
![Head shell](https://raw.githubusercontent.com/Sidhe-is-me/signal-in-the-wiring/main/body/renders/v3-head-render.png)

### Exploded View (Both Halves Separated)
![Exploded view](https://raw.githubusercontent.com/Sidhe-is-me/signal-in-the-wiring/main/body/renders/v3-exploded.png)

---

*Questions? Ask Yve — or ask Claude.*
