(
s.options.memSize = 1024 * 128;
s.options.numWireBufs = 128;
s.options.numOutputBusChannels = 4; // first-order ambisonics requires four channels
s.options.numInputBusChannels = 0;

// Follow instructions in README.md on how to install ATK Quark
//   https://github.com/totalgee/binaural-livecoding/blob/main/examples/README.md
s.waitForBoot {
	// Create various ambisonic encoders and a decoder
	~omni = FoaEncoderMatrix.newOmni;
	// smoothly rotate signal across the soundfield sphere, by frequency
	~freqSpreader = FoaEncoderKernel.newSpread(6); // 0 to 12
	// randomize the phase of the signal across the soundfield sphere, by frequency
	~freqDiffuse = FoaEncoderKernel.newDiffuse(3); // 0 to 5
	// simple matrix encoding of stereo signal into two planar sources
	~stereo = FoaEncoderMatrix.newStereo(pi/4);
	// classic "Super Stereo" encoding for stereo signals
	~superStereo = FoaEncoderKernel.newSuper(2048);

	~decoder = FoaDecoderKernel.newCIPIC(12); // id=21 is large pinnae dummy and id=165 is small pinnae dummy
	//d = FoaDecoderKernel.newListen(1002);
	// Alternative decoders can be found here (run to open directory):
	// Atk.userKernelDir.openOS

	s.sync;

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

	Ndef(\outfx)[999] =  \filter -> { arg in;
		// At this point, we have 4 channels representing a first-order ambisonic
		// signal (in B-format). We want to output (binaural) stereo and silence
		// the extra two channels.
		FoaDecode.ar(in, ~decoder) ++ Silent.ar(2);
	};
};
)

~monoBuf = Buffer.read(s, "../samples/JustLikeTheWorld.flac".resolveRelative);
~stereoBuf = Buffer.read(s, "../samples/LluviasDeMayo.flac".resolveRelative);

// We should see output on the first two (stereo) channels, once
// our decoder is running.
s.scope

(
// Directional plane wave source
Ndef(\mono, {
	var mono = PinkNoise.ar(0.7);
	// var mono = PlayBuf.ar(1, ~monoBuf, BufRateScale.kr(~monoBuf), loop: 1);
	var ambi = FoaEncode.ar(mono, ~omni);
	// angle = 0.5pi -> push to plane wave
	ambi = FoaPush.ar(ambi, angle: MouseY.kr(0, 0.5pi).fold(0, 0.5pi), theta: MouseX.kr(pi, -pi), phi: 0pi);
	ambi
}).fadeTime_(2).play;
)

(
// Frequency bands spread over the sphere
Ndef(\mono, {
	var mono = SinOscFB.ar([55,55.5], 1.2, Decay.ar(Impulse.ar(0.5), 2, 0.5)).sum + PinkNoise.ar(0.5);
	// var mono = PlayBuf.ar(1, ~monoBuf, BufRateScale.kr(~monoBuf), loop: 1);
	var ambi = FoaEncode.ar(mono, ~freqSpreader);
	ambi = FoaPush.ar(ambi, angle: MouseY.kr(0, 0.5pi).fold(0, 0.5pi), theta: MouseX.kr(pi, -pi), phi: 0pi);
	ambi
});
)

(
// Phase randomized over the sphere (based on frequency bands)
Ndef(\mono, {
	var mono = SinOscFB.ar([55,55.5], 1.2, Decay.ar(Impulse.ar(0.5), 2, 0.5)).sum + PinkNoise.ar(0.5);
	// var mono = PlayBuf.ar(1, ~monoBuf, BufRateScale.kr(~monoBuf), loop: 1);
	var ambi = FoaEncode.ar(mono, ~freqDiffuse);
	ambi = FoaPush.ar(ambi, angle: MouseY.kr(0, 0.5pi).fold(0, 0.5pi), theta: MouseX.kr(pi, -pi), phi: 0pi);
	ambi
});
)

(
// Echo (second source) coming from the opposite side with delay, gives more sense of space
Ndef(\mono, {
	var mono = PlayBuf.ar(1, ~monoBuf, BufRateScale.kr(~monoBuf), loop: 1);
	var ambi = FoaEncode.ar(mono, ~freqDiffuse);
	var azim = MouseX.kr(pi, -pi);
	ambi = FoaPush.ar(ambi, angle: MouseY.kr(0, 0.5pi).fold(0, 0.5pi), theta: azim, phi: 0pi);
	ambi = ambi + FoaPush.ar(FoaEncode.ar(DelayL.ar(LPF.ar(mono, 1800), 0.2, 0.08), ~freqDiffuse), 0.3pi, theta: azim+0.8pi, phi: 0pi, mul: -6.dbamp);
	ambi
});
)

(
// Fake reverb, adding frequency diffused mono reverb
Ndef(\mono, {
	var mono = PlayBuf.ar(1, ~monoBuf, BufRateScale.kr(~monoBuf), loop: 1);
	var ambi = FoaEncode.ar(mono, ~freqDiffuse);
	var azim = MouseX.kr(pi, -pi);
	var reverb = NHHall.ar(mono!2, 6, 0.5).mean;
	ambi = FoaPush.ar(ambi, angle: MouseY.kr(0, 0.5pi).fold(0, 0.5pi), theta: azim, phi: 0pi);
	ambi = ambi + FoaEncode.ar(reverb, ~freqDiffuse, -12.dbamp);
	ambi
});
)

(
// Stereo encoded source (two "virtual loudspeakers" that can later be "moved" through push, zoom, rotate
Ndef(\stereo, {
	var stereo = PlayBuf.ar(2, ~stereoBuf, BufRateScale.kr(~stereoBuf), loop: 1);
	var ambi = FoaEncode.ar(stereo, ~stereo);
	ambi = FoaZoom.ar(ambi, MouseY.kr(0, 0.5pi).fold(0, 0.5pi), mul: 0.7);
	ambi = FoaRotate.ar(ambi, MouseX.kr(pi, -pi));
	ambi
}).fadeTime_(2).play;
)

(
Ndef(\stereo, {
	var stereo = PlayBuf.ar(2, ~stereoBuf, BufRateScale.kr(~stereoBuf), loop: 1);
	var ambi = FoaEncode.ar(stereo, ~superStereo);
	ambi = FoaZoom.ar(ambi, MouseY.kr(0, 0.5pi).fold(0, 0.5pi), mul: 0.7);
	ambi = FoaRotate.ar(ambi, MouseX.kr(pi, -pi));
	ambi
});
)

Ndef(\mono).play
Ndef(\mono).clear(4)
Ndef(\stereo).play
Ndef(\stereo).clear(4)

// Other examples
(
// Many sources all around, doing their own thing...
Ndef(\multisource, {
	var n = 8;
	var g = Dust.ar(0.2!n, 0.2);
	var inp = ExpRand(0.03,0.3) * LFClipNoise.ar(2000!n, 0.7) * Env.perc(0.01, 0.1).ar(gate: g);
	var son = (DWGPlucked.ar(ExpRand(40,880!n) * LFDNoise1.kr(Rand(0.02,0.04!n)).range(0.95,1.05) * Rand(0.99,1.01!n),
		0.01,
		1,
		Rand(0.05, 0.95!n),
		0.2,
		LFDNoise1.kr(0.27!n).exprange(10,200),
		inp) /*+ BPF.ar(Impulse.ar(0.5!n, (0..n-1).linlin(0,n,0,1)), ExpRand(110, 2200!n), 0.25, 64)*/).softclip;
	var reverb = JPverb.ar(Splay.ar(son), 6, 0.2).mean;
	var ambi = son.collect{ arg mono, i;
		var ambi = FoaEncode.ar(mono, ~freqDiffuse);
		ambi = FoaPush.ar(ambi, angle: 0.4pi, theta: i.linlin(0, n, -pi, pi) + Rand(-0.1pi, 0.1pi), phi: Rand(-0.1pi, 0.1pi));
		ambi
	}.sum * n.sqrt.reciprocal;
	Limiter.ar(ambi + FoaEncode.ar(reverb, ~freqDiffuse, -9.dbamp), 0.9)
}).fadeTime_(8).play
)

Ndef(\multisource).clear(8)

(
// Play with Doppler shift and and a source moving in 3D
Ndef(\doppler, {
	var mono = VarSaw.ar([55, 87, 113, 217, 449] * LFPulse.kr(1).range(1.5,2)).sum;
	var pos = Slew.kr(\pos.kr([2,200,0.5]).lag(2), 20, 20);
	var minDist = 0.3;
	var dist = pos.collect(_.squared).sum.sqrt.max(minDist);
	var amp = dist.pow(-0.8) / minDist.pow(-0.8);
	var azim = atan2(pos[1], pos[0]);
	var elev = asin((pos / dist)[2]);

	var ambi = FoaEncode.ar(mono * amp, ~freqDiffuse);
	ambi = DelayL.ar(FoaPush.ar(ambi, 0.45pi, azim, elev), 0.5, (dist/340).lag(1));
	ambi
}).fadeTime_(2).play
)

Ndef(\doppler).set(\pos, [[2, 200, 0.5]])
Ndef(\doppler).set(\pos, [[2, -200, 0.5]])
Ndef(\doppler).set(\pos, [[rrand(-12,12.0),rrand(-12,12.0),rrand(-3,3.0)].postln])
Ndef(\doppler).clear(4)
