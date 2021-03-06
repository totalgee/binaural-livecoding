# Binaural live coding

<img align="left" height="400px" src="docs/binaural-curious.jpg">

Materials for a workshop on binaural audio and (you guessed it) live
coding, with some "setup" examples to get started with SuperCollider
and TidalCycles (SuperDirt).

For a higher-level overview of binaural audio, see the
[slides](docs/toplapSlides.pdf) from our TOPLAP Barcelona workshop in
November 2020, which were prepared and presented by Timothy Schmele.
The workshop was a "three-hander", as Niklas Reppel also presented
examples for live coding with binaural audio via a digital audio
workstation and plugins, while Glen Fraser presented his
SuperCollider and TidalCycles (SuperDirt) live coding workflows and
the examples from this repository.

See [README](examples/README.md) in the `examples` directory for help
installing the Ambisonic Toolkit (ATK) in SuperCollider. Or just
follow the very good
[introduction and setup](http://doc.sccode.org/Guides/Intro-to-the-ATK.html)
in regular SuperCollider documentation.

The [other README](hrir/README.md) in the `hrir` directory gives a
few links for sites to find head-related (directional) impulse
responses, to use with the direct convolution approach.

Once you've got the ATK and some impulse response files installed,
you're ready to dive into the examples.

## TidalCycles (SuperDirt)

If you use [TidalCycles](https://tidalcycles.org/), try one or both
of the following setups. In both cases, the `pan` argument in
Tidal/SuperDirt uses 0.5 for forward centre, 0.25 for left, 0.75 for
right, and 0 (or 1) for behind.

- [setup-superdirt-atk.scd](examples/setup-superdirt-atk.scd)
  sets up panning (in a horizontal plane) using the
  [ATK](https://www.ambisonictoolkit.net/) in conjunction with
  SuperDirt/Tidal's `pan` argument.
- [setup-superdirt-conv.scd](examples/setup-superdirt-conv.scd)
  works with eight audio outputs (could be real speakers or
  "virtual"), assumed to be in a circle. An output Synth is created
  to convolve with the directions of each output's "virtual speaker",
  producing a binaural stereo result on the first two outputs. This
  setup can also be used "just with SuperCollider", as it convolves
  the eight channels of output to produce binaural stereo, regardless
  of the source.

## SuperCollider

If you "just" use [SuperCollider](https://supercollider.github.io/),
you can still try the `setup-superdirt-conv.scd` example, and output
whatever you want to eight channels (it can be reconfigured for
different number of outputs and/or speaker placements).

To go down a deeper rabbit hole with ambisonics, you may also try the
[supercollider-atk.scd](examples/supercollider-atk.scd) example,
which configures SC to have four audio channels. In this case, they
are not "to be played" as audio -- they represent the four channels
of first-order ambisonic B-format (omnidirectional on channel 0,
followed by directional spherical harmonics). A decoder Synth runs on
the final SC output, so any Ndefs or Synths played to the SC outputs
are assumed to be in B-format (should have been encoded using
`FoaEncode`), and will be decoded (by a Synth in a Group following
SC's default Group on the server) to produce binaural stereo.

If you want to experiment with higher-order ambisonics (2nd-5th order)
in SuperCollider, you may try the
[SC-HOA Quark](https://github.com/florian-grond/SC-HOA), now part of
the normal Quark distribution. In particular, 3rd order (requiring 16
audio channels for the spherical harmonics) seems to be a reasonable
"sweet spot", offering considerably more spatial precision without
overly-heavy CPU processing requirements. *To do: add an example
using SC-HOA.* Another option is to use the excellent
[VSTPlugin](https://git.iem.at/pd/vstplugin/-/releases) extension to
instantiate VST encoding/decoding plugins -- such as those from
[IEM](https://plugins.iem.at/) -- within SC Synths.

## Routing audio to a DAW for binaural processing

Niklas showed an alternative approach which can be used in live
coding, using spatialization plug-ins running in a digital audio
workstation. Audio sources are piped from SuperCollider to the DAW
for binaural encoding/decoding there. Here are links to some tools
shown in Niklas' part of the workshop:

- [Anaglyph](http://anaglyph.dalembert.upmc.fr/) high-definition
  binaural spatialization plugin.
- [BlackHole](https://github.com/ExistentialAudio/BlackHole) for
  routing audio between applications on macOS.
- [SoundFlower](https://github.com/mattingalls/Soundflower/releases)
  as an older alternative for inter-app audio routing on Mac (old but
  may still work).
- [IEM Plug-in Suite](https://plugins.iem.at/) for ambisonic encoding,
  decoding, visualization and other effects.
- [Reaper](https://www.reaper.fm/) is the DAW Niklas was using.
