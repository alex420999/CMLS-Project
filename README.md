<h1 align="center">POLIcalling</h1>

## Introduction

The goal of the POLIcalling project is to create an additive-synthesis synthesizer with three oscillators designed to work in tight integration with any DAW.

The result is a standalone instrument that receives MIDI input from the DAW keyboard (in our case Ableton) and sends the processed signal directly to an audio track of the same program, ensuring seamless integration between the two components.

This synthesizer not only offers control over essential parameters—such as the volume ADSR envelope—but also leverages JUCE technology to create and modulate audio effects like chorus and reverb.

Finally, thanks to the use of an Arduino UNO, the project delivers a dynamic and engaging user experience: physical sensors and controls allow real-time sound shaping, making every performance unique and alive.

---

## Index

1. [Synth Module](#synth-module)  
2. [Audio Plugin Module](#audio-plugin-module)  
   a. [Audio Effects](#audio-effects)  
      - [Reverb Effect](#reverb-effect)  
      - [Chorus Effect](#chorus-effect)  
   b. [Graphical User Interface (GUI)](#graphical-user-interface-gui)  
   c. [Main Libraries & Modules Used](#main-libraries--modules-used)  
3. [Arduino UNO Module](#arduino-uno-module)

---

## Synth Module

The synthesizer is built around three independent oscillators, each capable of selecting from seven different waveforms. Each oscillator has its own slider for precise volume control.

To enrich the sound, each oscillator features an ensemble effect that simulates multiple similar but slightly out-of-tune oscillators, adding texture and depth to the overall sound.

A single ADSR envelope controls the volume of all three oscillators, allowing you to shape the attack, decay, sustain, and release in a simple and intuitive way. Additionally, there is a Low Pass Filter (LPF), Resonant High-Pass Filter (RHPF), High-Pass Filter (HPF), and Resonant Low-Pass Filter (RLPF) that can be adjusted via a slider. Each of the four filters acts on all oscillators simultaneously, shaping the overall tonal character and enriching the synth sound.

The sound synthesis itself is implemented in SuperCollider, offering detailed control and high audio quality. Meanwhile, the graphical interface, including control sliders and real-time waveform display, has been developed in Processing, offering dynamic interaction and immediate visual feedback.

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

## Arduino UNO Module

### Sensor Interaction Logic

In this project we wanted to turn two simple sensors into a controller for a fun and interactive performance. It works like this:

- **Touch → Trigger**  
  When your finger touches the capacitive touch, it doesn't just register a click, it activates the waiting light sensor.

- **On-demand light sampling**  
  The ambient light sensor instantly records the current readings of R, G, B and Clear (brightness).

- **Real-time timbre modulation**  
  These four numbers (R, G, B, C) are then transmitted by Arduino to the Processing application that processes them and uses them to change the synthesizer parameters on SuperCollider. The R, G and B values respectively change the waveform choice on oscillators 1, 2 and 3. The brightness C value instead adjusts the parameter dedicated to the filter. Finally, the touch sensor is used to change the ADSR “attack” value based on the time interval between one touch and the next on the sensor pad.
