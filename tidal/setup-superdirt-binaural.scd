(
s.options.numBuffers = 1024 * 256;
s.options.memSize = 8192 * 16;
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 8; // total number of channels output
s.options.numInputBusChannels = 2;

s.waitForBoot {
	~dirt = SuperDirt(8, s); // pan across eight channels
	~dirt.loadSoundFiles;
	~dirt.start(57120, [0, 0, 0, 0, 0, 0]);
};
s.latency = 0.2;
);

s.scope; // show 8 channels

(
s.waitForBoot {
	var hrtfPath, hrtfFiles;
	~binauralGroup = Group.after(s.defaultGroup).register;
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
	~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
	s.sync;
	Ndef(\outfx)[999] =  \filter -> { arg in;
		// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
		var shiftPan = PanAz.ar(8, in, (-1..6)/4).sum;
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
(
var hrtfPath = "../hrtf/D1_BRIR_WAV_48/";
var hrtfFiles = [
	"azi_0,0_ele_0,0.wav",
	"azi_315,0_ele_0,0.wav",
	"azi_270,0_ele_0,0.wav",
	"azi_225,0_ele_0,0.wav",
	"azi_180,0_ele_0,0.wav",
	"azi_135,0_ele_0,0.wav",
	"azi_90,0_ele_0,0.wav",
	"azi_45,0_ele_0,0.wav"
].collect(hrtfPath ++ _);
~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.resolveRelative, channels: [ch]) } };
)
(
Ndef(\outfx)[999] =  \filter -> { arg in;
	// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
	var shiftPan = PanAz.ar(8, in, (-1..6)/4).sum;
	var binaural = ~hrtfBufs.collect{ arg bufs, i;
		Convolution2.ar(shiftPan[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
	}.sum * ~hrtfBufs.size.sqrt.reciprocal;
	binaural
};
)


// Other impulse responses
(
var hrtfPath = "./hrtf/D1_HRIR_WAV_48/";
var hrtfFiles = [
	"azi_23,0_ele_0,0.wav",
	"azi_337,0_ele_0,0.wav",
	"azi_292,0_ele_0,0.wav",
	"azi_247,0_ele_0,0.wav",
	"azi_202,0_ele_0,0.wav",
	"azi_158,0_ele_0,0.wav",
	"azi_113,0_ele_0,0.wav",
	"azi_68,0_ele_0,0.wav"
].collect(hrtfPath ++ _);
~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.standardizePath, channels: [ch]) } };
)

(
Ndef(\outfx)[999] =  \filter -> { arg in;
	// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
	var binaural = ~hrtfBufs.collect{ arg bufs, i;
		Convolution2.ar(in[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
	}.sum * ~hrtfBufs.size.sqrt.reciprocal * 6.dbamp;
	JPverb.ar(binaural, 1, 0) * -18.dbamp + binaural
};
)


(
var hrtfPath = "./hrtf/listen_1002/";
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
~hrtfBufs = hrtfFiles.collect{ arg path; 2.collect{ arg ch; Buffer.readChannel(s, path.standardizePath, channels: [ch]) } };
)

(
Ndef(\outfx)[999] =  \filter -> { arg in;
	// At this point, we have 8 azimuth-panned channels in a circle, at 45 degree spacing
	var shiftPan = PanAz.ar(8, in, (-1..6)/4).sum;
	var binaural = ~hrtfBufs.collect{ arg bufs, i;
		Convolution2.ar(shiftPan[i], bufs, 0, (bufs[0].numFrames/2-1).nextPowerOfTwo);
	}.sum * ~hrtfBufs.size.sqrt.reciprocal * 6.dbamp;
	JPverb.ar(binaural, 1, 0) * -18.dbamp + binaural
};
)


// Useful links:
//   SuperDirt: https://github.com/musikinformatik/SuperDirt
//   Multichannel: https://tidalcycles.org/index.php/Multichannel_sound
//   Fixing "late" messages: https://tidalcycles.org/index.php/Configuration
