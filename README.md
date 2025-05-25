<h1 align="center">POLIcalling</h1>

## Introduction

The goal of the POLIcalling project is to create an additive-synthesis synthesizer with three oscillators designed to work in tight integration with any DAW.

The result is a standalone instrument that receives MIDI input from the DAW keyboard (in our case Ableton) and sends the processed signal directly to an audio track of the same program, ensuring seamless integration between the two components.

This synthesizer not only offers control over essential parameters—such as the volume ADSR envelope—but also leverages JUCE technology to create and modulate audio effects like chorus and reverb.

Finally, thanks to the use of an Arduino UNO, the project delivers a dynamic and engaging user experience: physical sensors and controls allow real-time sound shaping, making every performance unique and alive.

---

## Index

1. [Synth Module](#synth-module)  
   a. [Graphical User Interface (GUI)](#graphical-user-interface-gui)  
   b. [MIDI & OSC Control](#midi--osc-control)  
   c. [Key SuperCollider Components](#key-supercollider-components)  
2. [Audio Plugin Module](#audio-plugin-module)  
   a. [Audio Effects](#audio-effects)  
      - [Reverb Effect](#reverb-effect)  
      - [Chorus Effect](#chorus-effect)  
   b. [Graphical User Interface (GUI)](#graphical-user-interface-gui)  
   c. [Main Libraries & Modules Used](#main-libraries--modules-used)  
3. [Interaction Module](#interaction-module)

---

## Synth Module

### a. 🖥️ Graphical User Interface (GUI)

#### 🎹 Oscillators & Ensemble
Each voice consists of three slightly detuned copies of the selected waveform, creating a richer texture when the ensemble feature is enabled.  
🧩 **Parameters**  
- **wave1, wave2, wave3**: Waveform selection (integer 0–6; sine, parabolic, triangle, blip, formant, saw, pulse)  
- **ens1, ens2, ens3**: Optional ensemble depth (0.10–1.0; set to 0 to disable)  
- **vol1, vol2, vol3**: Level of each oscillator (0.0–1.0; user-controlled via sliders)

#### 🎚️ ADSR Envelope
A single ADSR envelope controls the volume of all three oscillators, allowing you to shape the attack, decay, sustain, and release in a simple and intuitive way.  
🧩 **Parameters**  
- **att**: Attack time (0.001–2 s)  
- **dec**: Decay time (0.001–2 s)  
- **sust**: Sustain level (0.0–1.0)  
- **rel**: Release time (0.001–3 s)

#### 🔊 Filter
Audio is routed through **one** of four selectable filters—only the active filter processes the signal. Each acts on all oscillators simultaneously, shaping the overall tonal character.  
🧩 **Filter Types**  
- **Resonant Low-Pass (RLPF)** (lets lows pass, boosts around cutoff)  
- **Low-Pass (LPF)** (smoothly cuts highs)  
- **Resonant High-Pass (RHPF)** (lets highs pass, boosts around cutoff)  
- **High-Pass (HPF)** (smoothly cuts lows)  

Cutoff frequency is adjusted via a slider (0.0–1.0, mapped log-scale 20 Hz–20 kHz).

---

### b. 🎛️ MIDI & OSC Control
- **MIDI**:  
  - `noteOn` → instantiate synth with note frequency & velocity  
  - `noteOff` → release envelope  
- **OSC**:  
  - `/wave [i1, i2, i3]` → set `wave1–3`  
  - `/volumes [f1, f2, f3]` → set `vol1–3`  
  - `/ensemble [f1, f2, f3]` → set `ens1–3`  
  - `/env [att, dec, sust, rel]` → set ADSR parameters  
  - `/filter/type [0–3]` → select filter (0=RLPF, 1=LPF, 2=RHPF, 3=HPF)  
  - `/filter/freq [0.0–1.0]` → set cutoff frequency  

---

### c. 🛠️ Key SuperCollider Components
- **SynthDef / Synth**: defines and spawns the synth voices  
- **EnvGen.kr**: ADSR envelope generator  
- **Select.ar** + **Splay.ar**: waveform selection and detuned voice generation  
- **RLPF.ar, LPF.ar, RHPF.ar, HPF.ar**: selectable filter processing  
- **MIDIdef**: MIDI event handling  
- **OSCdef**: OSC parameter updates  

---

## Audio Plugin Module

### 🔧 Overview

**Audio Plugin Module** is a cross-platform audio plugin built using the JUCE framework. It integrates two high-quality audio effects—**Reverb** and **Chorus**—with a carefully designed user interface that enables intuitive real-time control. The plugin supports VST3, AU, and standalone formats.

---

### a. 🎛️ Audio Effects

#### 1. **Reverb Effect**  
Adds spatial depth and ambience to the sound by simulating natural room reflections.

##### 🧩 Parameters:
- **Size (`size`)**: Controls the virtual room size (0%–100%)
- **Damping (`damp`)**: Controls high-frequency absorption (0%–100%)
- **Width (`width`)**: Adjusts stereo spread (0%–100%)
- **Mix (`mix`)**: Sets the wet/dry signal ratio (0%–100%)
- **Freeze (`freeze`)**: Freezes the reverb tail for ambient/sustain effects (boolean)

#### 2. **Chorus Effect**  
Modulates a delayed copy of the signal to create a rich, multi-voice texture.

##### 🧩 Parameters:
- **Rate (`rate`)**: Modulation speed of the LFO (Hz)
- **Depth (`depth`)**: Modulation intensity (0%–100%)
- **Centre Delay (`centreDelay`)**: Base delay around which modulation occurs (ms)
- **Feedback (`feedback`)**: Feeds part of the output back into the input (0%–100%)
- **Mix (`mixChorus`)**: Wet/dry balance (0%–100%)

##### 🛠️ Key JUCE Functions:
- `juce::Reverb`, `juce::dsp::Chorus` class for core effect
- `AudioProcessorValueTreeState` for parameter-value linking
- `SliderAttachment` and `ButtonAttachment` for GUI binding

---

### b. 🖥️ Graphical User Interface (GUI)

The interface is modular and responsive, composed of:

- `PluginEditor` – main container with scaling and keyboard handling
- `EditorContent` – inner component managing all effect controls

<p align="center">
  <img src="Images/Music Effects Interface picture.JPG" width="70%" />
</p>

#### 🖼️ Layout Features:
- Sliders grouped and aligned for **Reverb** and **Chorus** effects
- Use of `explicitFocusOrder` for keyboard accessibility
- Visual feedback through color themes (`MyColours`) and custom styling

---

### c. 📚 Main Libraries & Modules Used

| JUCE Module                      | Purpose                                  |
|----------------------------------|------------------------------------------|
| `juce_audio_processors`          | Plugin framework & parameter management  |
| `juce_dsp`                       | Audio effect algorithms (Reverb/Chorus)  |
| `juce_gui_basics/extra`          | GUI components, sliders, buttons         |
| `juce_core`, `data_structures`   | Utilities and internal data binding      |

---

## Interaction Module

### Sensor Interaction Logic

In this project we wanted to turn two simple sensors into a controller for a fun and interactive performance. It works like this:

- **Touch → Trigger**  
  When your finger touches the capacitive touch, it doesn't just register a click, it activates the waiting light sensor.

- **On-demand light sampling**  
  The ambient light sensor instantly records the current readings of R, G, B and Clear (brightness).

- **Real-time timbre modulation**  
  These four numbers (R, G, B, C) are then transmitted by Arduino to the Processing application that processes them and uses them to change the synthesizer parameters on SuperCollider. The R, G and B values respectively change the waveform choice on oscillators 1, 2 and 3. The brightness C value instead adjusts the parameter dedicated to the filter. Finally, the touch sensor is used to change the ADSR “attack” value based on the time interval between one touch and the next on the sensor pad.
