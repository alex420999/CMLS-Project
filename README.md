<h1 align="center">POLIcalling</h1>

## Introduction

The goal of the POLIcalling project is to create an additive-synthesis synthesizer with three oscillators designed to work in tight integration with any DAW.

The result is a standalone instrument that receives MIDI input from the DAW keyboard (in our case Ableton) and sends the processed signal directly to an audio track of the same program, ensuring seamless integration between the two components.

This synthesizer not only offers control over essential parameters—such as the volume ADSR envelope—but also leverages JUCE technology to create and modulate audio effects like chorus and reverb.

Finally, thanks to the use of an Arduino UNO, the project delivers a dynamic and engaging user experience: physical sensors and controls allow real-time sound shaping, making every performance unique and alive.

---

## Index

1. [Synth Module](#synth-module)  
2. [Music Effects Module](#music-effects-module)  
   a. [Chorus](#a-chorus)  
   b. [Reverb](#b-reverb)  
3. [Arduino UNO Module](#arduino-uno-module)  

---

## Synth Module

The synthesizer is built around three independent oscillators, each capable of selecting among seven different waveforms. Each oscillator has its own slider for precise volume control.

To enrich the sound, each oscillator features an ensemble effect that simulates multiple similar but slightly detuned oscillators, adding thickness and depth to the overall timbre.

A single ADSR envelope controls the volume of all three oscillators, allowing attack, decay, sustain, and release to be shaped simply and intuitively. In addition, a low-pass filter (LPF) adjustable via a slider acts simultaneously on all oscillators, modulating the overall tonal character.

The sound synthesis itself is implemented in SuperCollider, providing detailed control and high audio quality. Meanwhile, the graphical interface—including the control sliders and a real-time waveform display—was developed in Processing, offering dynamic interaction and immediate visual feedback.

---

## Music Effects Module

After being processed by SuperCollider, the audio signal returns to the DAW where it can be routed to a dedicated audio track. On this track, JUCE-powered audio effects are applied in series, adding a new expressive dimension to the sound.

The main effects developed for POLIcalling are Chorus and Reverb, implemented entirely with JUCE to enrich the timbre with depth, movement, and spatiality—greatly expanding creative possibilities.

<div align="center">
  <img src="Images/Music Effects Interface picture.JPG" alt="Interfaccia JUCE effetti Chorus e Riverbero" width="70%" />
</div>

### a. Chorus

- **Rate**  
  Defines the oscillation frequency of the LFO that modulates the delay time. Low rate settings produce slow, undulating modulations; high values yield fast, vibrato-like effects.

- **Depth**  
  Determines how much the LFO deviates the delay time. Low depth yields subtle, natural chorus; higher depth produces wider pitch excursions and a more “liquid” character.

- **CentreDelay**  
  Sets the base delay time around which the LFO applies modulation. Short centreDelay creates a bright, tight chorus; longer values make the effect more pronounced, approaching a modulated doubling.

- **Feedback**  
  Controls how much of the processed signal is fed back into the chorus loop. Positive feedback reinforces the effect’s resonance; negative feedback introduces phase inversions, creating unique timbral interferences.

- **MixChorus**  
  Balances the clean (dry) and processed (wet) signals. Low settings keep the chorus in the background; high settings bring the modulated effect to the forefront.

### b. Reverb

- **Size**  
  Adjusts the overall decay time (RT60) by simulating different room sizes. Increasing size yields a longer decay tail, as in a large hall; reducing it shortens the tail, typical of smaller rooms.

- **Damp**  
  Sets the high-frequency damping coefficient in the reverb feedback network. Low damping lets high frequencies persist longer for a bright reverb; higher damping applies stronger low-pass filtering, darkening the tail.

- **Freeze (∞)**  
  Activates a buffer freeze: the current reverb buffer content is locked in a unit-gain feedback loop, creating an infinite decay as long as the control remains enabled.

- **Width**  
  Controls the stereo distribution of the reverb feedback. Narrow width keeps the signal centered; wider width introduces phase shifts between left and right channels, creating a broader stereo image.

- **Mix**  
  Crossfades between the original (dry) and processed (wet) signals. Moderate settings add depth without overwhelming the original envelope; high values immerse the sound in reflections.

---

## Arduino UNO Module

### Hardware and Sensors

Description of the hardware and sensors used.

### Basic Programming and Interaction

Basic Arduino programming concepts and interaction methods with the synthesizer.
