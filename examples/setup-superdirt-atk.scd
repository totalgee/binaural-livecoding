(
s.options.numBuffers = 1024 * 256;
s.options.memSize = 1024 * 128;
s.options.numWireBufs = 64;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 2; // total number of channels output
s.options.numInputBusChannels = 0;

s.waitForBoot {
	~dirt = SuperDirt(2, s); // pan across eight channels
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
e = FoaEncoderMatrix.newOmni;
d = FoaDecoderKernel.newCIPIC(12); // id=21 is the large pinnae dummy and id=165 is the small pinnae dummy.
//d = FoaDecoderKernel.newListen(1002);
)

(
DirtPan.defaultPanningFunction = { |signals, numChannels, pan, mul|
	var sig = FoaEncode.ar(signals.sum * mul, e);
	// angle=0.5pi -> push to plane wave
	sig = FoaPush.ar(sig, angle: 0.5pi, theta: pan * pi, phi: 0);
	FoaDecode.ar(sig, d);
};

// Reload synthdefs after replacing panning function
~dirt.loadSynthDefs;
)

SuperDirt.default = ~dirt;
// Play sounds clockwise from centre (ahead)
// 0 is ahead, 0.25 is right, 0.5 is behind, 0.75 is left
Pbind(*[type: \dirt, orbit: 0, s: \cr, pan: Pseq((0,0.125..0.99))]).play
(type: \dirt, orbit: 0, s: \sd, pan: 1.0.rand).play
(type: \dirt, orbit: 1, s: \bd, speed: 1, pan: gaussian(0, 0.2)).play;
(type: \dirt, orbit: 0, s: \sd, pan: [0.25,0.75].choose, room: 0.1, size: 0.8).play
