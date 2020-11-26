# Binaural live coding

<img align="left" height="300px" src="images/binaural-curious.jpg">

Materials for a workshop on binaural audio and -- you guessed it --
live coding, with some "setup" examples to get started with
SuperCollider and TidalCycles (SuperDirt).

See [README](examples/README.md) in the `examples` directory for help
installing the Ambisonic Toolkit (ATK) in SuperCollider. Or just
follow the very good
[introduction and setup](http://doc.sccode.org/Guides/Intro-to-the-ATK.html)
in regular SuperCollider documentation.

The [other README](hrir/README.md) in the `hrir` directory gives a
few links for sites to find head-related (directional) impulse
responses, to use with the direct convolution approach.

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
`FoaEncode`), and will be decoded (in a Group following SC's default
Group) to produce binaural stereo.

If you want to experiment with higher-order ambisonics (2nd-5th order)
in SuperCollider, you may try the
[SC-HOA Quark](https://github.com/florian-grond/SC-HOA), now part of
the normal Quark distribution. In particular, 3rd order (requiring 16
audio channels for the spherical harmonics) seems to be a reasonable
"sweet spot", offering considerably more spatial precision without
overly-heavy CPU processing requirements. *To do: add an example
using SC-HOA.*
