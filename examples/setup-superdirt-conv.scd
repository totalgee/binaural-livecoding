////////////////////////////////////////////////////////////
// PanAz + Convolution2 for binaural previewing of eight virtual speakers
// via SuperDirt (or not)
////////////////////////////////////////////////////////////
(
var numChannels = 8;
s.options.numBuffers = 1024 * 256;
s.options.memSize = 1024 * 128;
s.options.numWireBufs = 64;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = numChannels; // total number of "virtual speakers"
s.options.numInputBusChannels = 0;

s.waitForBoot {
	~dirt = SuperDirt(numChannels, s); // pan across eight channels
	~dirt.loadSoundFiles;
	~dirt.start(57120, 0 ! 6);
};
s.latency = 0.2;
);

// Useful links:
//   SuperDirt: https://github.com/musikinformatik/SuperDirt
//   Multichannel: https://tidalcycles.org/index.php/Multichannel_sound
//   Fixing "late" messages: https://tidalcycles.org/index.php/Configuration

s.scope; // show 8 channels

// Ensure you have impulse response files (for the eight virtual
// speaker directions) in the local "hrir" directory, with the names
// of the ones you want to use set below, under "hrirFiles".
(
s.waitForBoot {
	var hrirPath, hrirFiles;
	~binauralGroup = ~binauralGroup ?? {
		var controller;
		var group = Group.after(s.defaultGroup).register;
		// Register a SimpleController here to free things
		// if the Group goes away on the Server
		controller = SimpleController(group).put(\n_end, { ~binauralGroup = nil; controller.remove });
		group
	};
	s.sync;
	Ndef(\outfx).parentGroup_(~binauralGroup).bus_(Bus(\audio, 0, 8, s));
	s.sync;
	hrirPath = "../hrir/D1_BRIR_WAV_48/";
	hrirFiles = [
		"azi_180,0_ele_0,0.wav", // behind
		"azi_135,0_ele_0,0.wav",
		"azi_90,0_ele_0,0.wav", // left
		"azi_45,0_ele_0,0.wav",
		"azi_0,0_ele_0,0.wav", // front
		"azi_315,0_ele_0,0.wav",
		"azi_270,0_ele_0,0.wav", // right
		"azi_225,0_ele_0,0.wav",
	].collect(hrirPath ++ _);
	if (~hrirBufs.notNil) {
		~hrirBufs.do{ arg bufs; bufs.do{ arg buf; buf.free} }
	};
	~hrirBufs = hrirFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
	s.sync;
	Ndef(\outfx)[999] =  \filter -> { arg in;
		// At this point, we have 8 azimuth-panned channels in a circle (45 degree spacing)
		// Rotate panning to ensure front is front
		var shiftPan = PanAz.ar(8, in, (0..7) / 4 - 0.125, orientation: 0).sum;
		var binaural = ~hrirBufs.collect{ arg bufs, i;
			// (Use PartConv instead of Convolution2 if you need
			// to convolve with large buffers)
			Convolution2.ar(shiftPan[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
		}.sum * ~hrirBufs.size.sqrt.reciprocal;
		binaural ++ Silent.ar(6)
	};
}
)


// You can try different HRIRs (impulse responses) from:
//   SADIE: https://www.york.ac.uk/sadie-project/database.html (non-dry, with reverb)
//   Listen: http://recherche.ircam.fr/equipes/salles/listen/download.html
//   CIPIC: https://www.ece.ucdavis.edu/cipic/spatial-sound/hrtf-data/
// SOFA convention:
//   https://www.sofaconventions.org/mediawiki/index.php/SOFA_(Spatially_Oriented_Format_for_Acoustics)

// Try with other impulse responses
(
var hrirPath = "../hrir/IRC_1002_C/";
var hrirFiles = [
	"IRC_1002_C_R0195_T180_P000.wav", // behind
	"IRC_1002_C_R0195_T135_P000.wav",
	"IRC_1002_C_R0195_T090_P000.wav", // left
	"IRC_1002_C_R0195_T045_P000.wav",
	"IRC_1002_C_R0195_T000_P000.wav", // front
	"IRC_1002_C_R0195_T315_P000.wav",
	"IRC_1002_C_R0195_T270_P000.wav", // right
	"IRC_1002_C_R0195_T225_P000.wav",
].collect(hrirPath ++ _);
if (~hrirBufs.notNil) {
	~hrirBufs.do{ arg bufs; bufs.do{ arg buf; buf.free} }
};
~hrirBufs = hrirFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
)

(
Ndef(\outfx)[999] =  \filter -> { arg in;
	// At this point, we have 8 azimuth-panned channels in a circle (45 degree spacing)
	// Rotate panning to ensure front is front
	var shiftPan = PanAz.ar(8, in, (0..7) / 4 - 0.125, orientation: 0).sum;
	var binaural = ~hrirBufs.collect{ arg bufs, i;
		Convolution2.ar(shiftPan[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
	}.sum * ~hrirBufs.size.sqrt.reciprocal;
	// Add a touch of reverb, since these impulses are dry
	JPverb.ar(binaural, 1.4, 0.2) * -18.dbamp + binaural ++ Silent.ar(6)
};
)

SuperDirt.default = ~dirt;
// pan 0 (and 1) is behind, 0.25 is left, 0.5 is ahead, 0.75 is right
(type: \dirt, orbit: 0, s: \sd, gain: 1.2, pan: 0.75).play
// Play sounds clockwise from centre (behind)
Pbind(*[type: \dirt, orbit: 0, s: \cr, gain: 1.2, pan: Pseq((0,0.125..0.99), 2).trace]).play
(type: \dirt, orbit: 0, s: \sd, pan: rrand(0.2,0.8), gain: 1.2).play
(type: \dirt, orbit: 1, s: \bd, speed: 1, pan: gaussian(0.5, 0.15), gain: 1.4).play;
(type: \dirt, orbit: 0, s: \sd, pan: [0.25,0.75].choose, room: 0.1, size: 0.8).play


(
// Don't need to use SuperDirt; you can just output any
// 8-channel signal to SuperCollider's main outputs and
// it will be spatialized by the \outfx proxy to play
// on "virtual" speakers.
Ndef(\multichan, {
	var n = 8;
	var sig = SinOscFB.ar(Rand(36, 86!n).round(2).midicps, ExpRand(0.4, 1.6!n), ExpRand(0.1,2!n)).softclip;
	sig = sig * Env.perc(0.01, 1).ar(gate: Impulse.ar((1..n)/n, Rand(-0.1,0.1!n)));
	// sig = sig + PanAz.ar(
	// 	n,
	// 	RLPF.ar(
	// 		PinkNoise.ar(LFDNoise3.kr(0.23).exprange(0.2,1)),
	// 		LFDNoise3.kr(0.17).exprange(80,2400),
	// 	0.2),
	// 	LFDNoise3.kr(0.19)
	// );
}).fadeTime_(4).play
)

Ndef(\multichan).clear(8)
