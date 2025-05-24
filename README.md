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

## Synth Module

The synthesizer is built around three independent oscillators, each capable of selecting from seven different waveforms. Each oscillator has its own slider for precise volume control.

To enrich the sound, each oscillator features an ensemble effect that simulates multiple similar but slightly out-of-tune oscillators, adding texture and depth to the overall sound.

A single ADSR envelope controls the volume of all three oscillators, allowing you to shape the attack, decay, sustain, and release in a simple and intuitive way. Additionally, there is a Low Pass Filter (LPF), Resonant High-Pass Filter (RHPF), High-Pass Filter (HPF), and Resonant Low-Pass Filter (RLPF) that can be adjusted via a slider. Each of the 4 filters acts on all oscillators simultaneously, shaping the overall tonal character and enriching the synth sound.

The sound synthesis itself is implemented in SuperCollider, offering detailed control and high audio quality. Meanwhile, the graphical interface, including control sliders and real-time waveform display, has been developed in Processing, offering dynamic interaction and immediate visual feedback.

---

## Music Effects Module

After being processed by SuperCollider, the audio signal returns to the DAW where it can be routed to a dedicated audio track. On this track, JUCE-powered audio effects are applied in series, adding a new expressive dimension to the sound.

The main effects developed for POLIcalling are Chorus and Reverb, implemented entirely with JUCE to enrich the timbre with depth, movement, and spatiality—greatly expanding creative possibilities.

<div align="center">
  <img src="Images/Music Effects Interface picture.JPG" alt="JUCE interface for Chorus and Reverb effects" width="70%" />
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

### Sensor Interaction Logic

In this project we wanted to turn two simple sensors into a controller for a fun and interactive performance. It works like this:

- **Touch → Trigger**  
  When your finger touches the capacitive touch, it doesn't just register a click, it activates the waiting light sensor.

- **On-demand light sampling**  
  The ambient light sensor instantly records the current readings of R, G, B and Clear (brightness).

- **Real-time timbre modulation**  
  These four numbers (R, G, B, C) are then transmitted by Arduino to the Processing application that processes them and uses them to change the synthesizer parameters on SuperCollider. The R, G and B value respectively change the waveform choice on oscillators 1, 2 and 3. The brightness C value instead adjusts the parameter dedicated to the filter. Finally the touch sensor is used to change the ADSR "attack" value based on the time interval between one touch and the next on the sensor pad.  
