(
s.options.numBuffers = 1024 * 256;
s.options.memSize = 1024 * 128;
s.options.numWireBufs = 64;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 2; // total number of channels output
s.options.numInputBusChannels = 0;

s.waitForBoot {
	~dirt = SuperDirt(2, s); // pan across two channels
	~dirt.loadSoundFiles;
	~dirt.start(57120, 0 ! 6);
};
s.latency = 0.2;
);

// Quarks.install("atk-sc3")
// Atk.createUserSupportDir
// Atk.openUserSupportDir
// Install:
// "kernels" from https://github.com/ambisonictoolkit/atk-kernels/releases/
// and "matrices" from https://github.com/ambisonictoolkit/atk-matrices/releases/
(
// Create encoder and decoder
// e = FoaEncoderMatrix.newOmni;
e = FoaEncoderKernel.newDiffuse(3); // 0 to 5
d = FoaDecoderKernel.newCIPIC(12); // id=21 is the large pinnae dummy and id=165 is the small pinnae dummy.
//d = FoaDecoderKernel.newListen(1002);
)

(
// We set panning to it goes clockwise around the head.
// Set up so that in "Tidal panning units":
//   pan 0.5 is ahead/centre, 0.25 is left, 0.75 is right, 0 (or 1) is behind
// (in this function, it's already been remapped from -1 to 1, so 0 is ahead, -1 and 1 are behind)
DirtPan.defaultPanningFunction = { |signals, numChannels, pan, mul|
	var sig = FoaEncode.ar(signals.sum * mul, e);
	// angle=0.5pi -> push to plane wave
	sig = FoaPush.ar(sig, angle: 0.4pi, theta: pan * -pi, phi: 0);
	FoaDecode.ar(sig, d);
};

// Reload synthdefs after replacing panning function
~dirt.loadSynthDefs;
)

SuperDirt.default = ~dirt;
// pan 0 (and 1) is behind, 0.25 is left, 0.5 is ahead, 0.75 is right
(type: \dirt, orbit: 0, s: \sd, gain: 1.2, pan: 0.75).play
// Play sounds clockwise from centre (behind)
Pbind(*[type: \dirt, orbit: 0, s: \cr, gain: 1.2, pan: Pseq((0,0.125..0.99), 2).trace]).play
(type: \dirt, orbit: 0, s: \sd, pan: rrand(0.2,0.8), gain: 1.2).play
(type: \dirt, orbit: 1, s: \bd, speed: 1, pan: gaussian(0.5, 0.15), gain: 1.4).play;
(type: \dirt, orbit: 0, s: \sd, pan: [0.25,0.75].choose, room: 0.1, size: 0.8).play
