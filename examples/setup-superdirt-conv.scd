(
s.options.numBuffers = 1024 * 256;
s.options.memSize = 1024 * 128;
s.options.numWireBufs = 64;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 8; // total number of channels output
s.options.numInputBusChannels = 0;

s.waitForBoot {
	~dirt = SuperDirt(8, s); // pan across eight channels
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

// Ensure you have some HRTF files (for the eight speaker directions) in the local "hrtf" directory
(
s.waitForBoot {
	var hrtfPath, hrtfFiles;
	~binauralGroup = ~binauralGroup ?? {
		var controller;
		var group = Group.after(s.defaultGroup).register;
		// Register a SimpleController here to free things if the Group goes away on the Server
		controller = SimpleController(group).put(\n_end, { ~binauralGroup = nil; controller.remove });
		group
	};
	s.sync;
	Ndef(\outfx).parentGroup_(~binauralGroup).bus_(Bus(\audio, 0, 8, s));
	s.sync;
	hrtfPath = "../hrtf/D1_BRIR_WAV_48/";
	hrtfFiles = [
		"azi_0,0_ele_0,0.wav",
		"azi_315,0_ele_0,0.wav",
		"azi_270,0_ele_0,0.wav",
		"azi_225,0_ele_0,0.wav",
		"azi_180,0_ele_0,0.wav",
		"azi_135,0_ele_0,0.wav",
		"azi_90,0_ele_0,0.wav",
		"azi_45,0_ele_0,0.wav"
	].collect(hrtfPath ++ _);
	if (~hrtfBufs.notNil) {
		~hrtfBufs.do{ arg bufs; bufs.do{ arg buf; buf.free} }
	};
	~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
	s.sync;
	Ndef(\outfx)[999] =  \filter -> { arg in;
		// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
		// If you want the front-left speaker to have pan of 0 (instead of 0=centre), use shiftPan
		// var shiftPan = PanAz.ar(8, in, (-1..6)/4).sum;
		var shiftPan = in;
		var binaural = ~hrtfBufs.collect{ arg bufs, i;
			Convolution2.ar(shiftPan[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
		}.sum * ~hrtfBufs.size.sqrt.reciprocal;
		binaural
	};
}
)


////////// PanAz + Convolution2 for binaural previewing
// You can try different HRTFs (impulse responses) from:
//   SADIE: https://www.york.ac.uk/sadie-project/database.html (non-dry, with reverb)
//   Listen: http://recherche.ircam.fr/equipes/salles/listen/download.html
//   CIPIC: https://www.ece.ucdavis.edu/cipic/spatial-sound/hrtf-data/
// SOFA convention:
//   https://www.sofaconventions.org/mediawiki/index.php/SOFA_(Spatially_Oriented_Format_for_Acoustics)

// Try with other impulse responses
(
var hrtfPath = "../hrtf/IRC_1002_C/";
var hrtfFiles = [
	"IRC_1002_C_R0195_T000_P000.wav",
	"IRC_1002_C_R0195_T315_P000.wav",
	"IRC_1002_C_R0195_T270_P000.wav",
	"IRC_1002_C_R0195_T225_P000.wav",
	"IRC_1002_C_R0195_T180_P000.wav",
	"IRC_1002_C_R0195_T135_P000.wav",
	"IRC_1002_C_R0195_T090_P000.wav",
	"IRC_1002_C_R0195_T045_P000.wav"
].collect(hrtfPath ++ _);
if (~hrtfBufs.notNil) {
	~hrtfBufs.do{ arg bufs; bufs.do{ arg buf; buf.free} }
};
~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
)

(
Ndef(\outfx)[999] =  \filter -> { arg in;
	// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
	var binaural = ~hrtfBufs.collect{ arg bufs, i;
		Convolution2.ar(in[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
	}.sum * ~hrtfBufs.size.sqrt.reciprocal;
	// Add a touch of reverb, since these impulses are dry
	JPverb.ar(binaural, 1, 0.2) * -21.dbamp + binaural
};
)

SuperDirt.default = ~dirt;
// Play sounds clockwise from centre (ahead)
// 0 is ahead, 0.25 is right, 0.5 is behind, 0.75 is left
Pbind(*[type: \dirt, orbit: 0, s: \cr, pan: Pseq((0,0.125..0.99))]).play
(type: \dirt, orbit: 0, s: \sd, pan: 1.0.rand).play
(type: \dirt, orbit: 1, s: \bd, speed: 1, pan: gaussian(0, 0.2)).play;
(type: \dirt, orbit: 0, s: \sd, pan: [0.25,0.75].choose, room: 0.1, size: 0.8).play
