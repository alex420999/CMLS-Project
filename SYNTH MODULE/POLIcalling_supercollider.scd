(
s.options.device = "BlackHole 2ch";

s.waitForBoot({
    MIDIIn.connectAll;
    MIDIdef.freeAll;

    SynthDef(\dualOscSynth, {
    |freq1 = 440, freq2 = 442, freq3 = 440,
	amp = 0.3, gate = 1, wave1 = 0, wave2 = 0, wave3 = 0,
	att = 0.01, dec = 0.2, sust = 0.5, rel = 0.5,
	lpfFreq = 20000, rlpfFreq = 20000,
	hpfFreq = 0, rhpfFreq = 0,
	vol1 = 1, vol2 = 1, vol3 = 1,
	ens1 = 0.3, ens2 = 0.3, ens3 = 0.3,
    pan1 = 0, pan2 = 0, pan3 = 0|

    var env = EnvGen.kr(Env.adsr(att, dec, sust, rel), gate, doneAction: 2);
    var sig1, sig2, sig3, mix, filteredL, filteredRL, filteredH, filteredRH;

    var ensemble = { |freq, wave, vol, depth|
        var detune = [0.99, 1.0, 1.01] * depth;
        var phases = Array.fill(3, { Rand(0.0, 2pi) });
        var voices = Array.fill(3, { |i|
            var f = freq * detune[i];
            Select.ar(wave.clip(0, 6), [
                SinOsc.ar(f, phases[i]),
				LFPar.ar(f),
			    LFTri.ar(f),
			    Blip.ar(f, 4),
				Formant.ar(f, f*2, 800),
                Saw.ar(f),
                Pulse.ar(f)
            ])
        });
        Splay.ar(voices, 1, 0.5) * vol;
    };

    sig1 = Pan2.ar(ensemble.(freq1, wave1, vol1, ens1), pan1);
    sig2 = Pan2.ar(ensemble.(freq2, wave2, vol2, ens2), pan2);
    sig3 = Pan2.ar(ensemble.(freq3, wave3, vol3, ens3), pan3);


    mix = (sig1 + sig2 + sig3) / 3;
 filteredRL = mix.collect { |chan| RLPF.ar(chan, rlpfFreq, 0.3) };
 filteredL  = filteredRL.collect { |chan| LPF.ar(chan, lpfFreq) };
 filteredRH = filteredL.collect { |chan| RHPF.ar(chan, rhpfFreq, 0.3) };
 filteredH  = filteredRH.collect { |chan| HPF.ar(chan, hpfFreq) };


    Out.ar(0, filteredH * env * amp);
    }).add;

    ~notes = IdentityDictionary.new;
    ~currentWave1 = 0;
    ~currentWave2 = 0;
    ~currentWave3 = 0;
    ~vol1 = 1.0;
    ~vol2 = 1.0;
    ~vol3 = 1.0;
    ~att = 0.01;
	~dec = 0.2;
	~sust = 0.5;
	~rel = 0.5;
    ~lpfFreq = 20000;
	~rlpfFreq = 20000;
	~hpfFreq = 0;
	~rhpfFreq = 0;
    ~ens1 = 0.3;
    ~ens2 = 0.3;
    ~ens3 = 0.3;
	~pan1 = 0;
    ~pan2 = 0;
    ~pan3 = 0;


    MIDIdef.noteOn(\noteOn, { |vel, note, chan, src|
        var freq = note.midicps;
        var synth = Synth(\dualOscSynth, [
            \freq1, freq,
            \freq2, freq * 0.995,
            \freq3, freq,
            \amp, vel / 127,
            \wave1, ~currentWave1,
            \wave2, ~currentWave2,
            \wave3, ~currentWave3,
            \att, ~att,
			\dec, ~dec,
			\sust, ~sust,
			\rel, ~rel,
            \lpfFreq, ~lpfFreq, \rlpfFreq, ~rlpfFreq,
			\hpfFreq, ~hpfFreq, \rhpfFreq, ~rhpfFreq,
            \vol1, ~vol1, \vol2, ~vol2, \vol3, ~vol3,
            \ens1, ~ens1, \ens2, ~ens2, \ens3, ~ens3,
			\pan1, ~pan1, \pan2, ~pan2, \pan3, ~pan3
        ]);
        ~notes[note] = synth;
    });

    MIDIdef.noteOff(\noteOff, { |vel, note, chan, src|
        ~notes[note].set(\gate, 0);
    });

    OSCdef(\waveOSC, { |msg|
        if (msg.size >= 4) {
            var val1 = msg[1].clip(0, 6).asInteger;
            var val2 = msg[2].clip(0, 6).asInteger;
            var val3 = msg[3].clip(0, 6).asInteger;
            ~currentWave1 = val1;
            ~currentWave2 = val2;
            ~currentWave3 = val3;
            ~notes.do { |synth|
                synth.set(\wave1, val1, \wave2, val2, \wave3, val3);
            };
        }
    }, '/wave');

    OSCdef(\volumes, { |msg|
        if (msg.size >= 4) {
            ~vol1 = msg[1].clip(0, 1);
            ~vol2 = msg[2].clip(0, 1);
            ~vol3 = msg[3].clip(0, 1);
            ~notes.do { |synth|
                synth.set(\vol1, ~vol1, \vol2, ~vol2, \vol3, ~vol3);
            };
        }
    }, '/volumes');

    OSCdef(\ensembleOSC, { |msg|
        if (msg.size >= 4) {
            ~ens1 = msg[1].clip(0.10, 1.0);
            ~ens2 = msg[2].clip(0.10, 1.0);
            ~ens3 = msg[3].clip(0.10, 1.0);
            ~notes.do { |synth|
                synth.set(\ens1, ~ens1, \ens2, ~ens2, \ens3, ~ens3);
            };
        }
    }, '/ensemble');

    OSCdef(\envOSC, { |msg|
        if (msg.size >= 5) {
            ~att = msg[1].clip(0.001, 2);
            ~dec = msg[2].clip(0.001, 2);
            ~sust = msg[3].clip(0, 1);
            ~rel = msg[4].clip(0.001, 3);
        }
    }, '/env');




OSCdef(\lpf, { |msg|
    ~lpfFreq = msg[1].clip(50, 20000);
    ~notes.do { |synth|
        synth.set(\lpfFreq, ~lpfFreq);
    };
}, '/filter/lpf');

OSCdef(\rlpf, { |msg|
    ~rlpfFreq = msg[1].clip(50, 20000);
    ~notes.do { |synth|
        synth.set(\rlpfFreq, ~rlpfFreq);
    };
}, '/filter/rlpf');

OSCdef(\hpf, { |msg|
    ~hpfFreq = msg[1].clip(50, 20000);
    ~notes.do { |synth|
        synth.set(\hpfFreq, ~hpfFreq);
    };
}, '/filter/hpf');

OSCdef(\rhpf, { |msg|
    ~hpfFreq = msg[1].clip(50, 20000);
    ~notes.do { |synth|
        synth.set(\rhpfFreq, ~rhpfFreq);
    };
}, '/filter/rhpf');

	OSCdef(\pans, { |msg|
    if (msg.size >= 4) {
        ~pan1 = msg[1].clip(-1, 1);
        ~pan2 = msg[2].clip(-1, 1);
        ~pan3 = msg[3].clip(-1, 1);
        ~notes.do { |synth|
            synth.set(\pan1, ~pan1, \pan2, ~pan2, \pan3, ~pan3);
        };
    }
}, '/pans');




});

s.reboot;
)