## Ambisonic Toolkit (ATK) setup in SuperCollider

To follow along with some of the examples and experiment more with
binaural audio, you should install the Ambisonic Toolkit (ATK) Quark
in SuperCollider.

Be sure you have the [SC3-plugins](https://supercollider.github.io/sc3-plugins/)
installed (if not, follow the instructions on the website):

```supercollider
Platform.userExtensionDir.openOS
// (you should see an "SC3plugins" directory there)
```

Install the ATK Quark:

```supercollider
Quarks.install("atk-sc3")
// (now recompile the SC language using Ctrl-Shift-L (Cmd-Shift-L on Mac))
```

Download the following data files:

- [ATK kernels](https://github.com/ambisonictoolkit/atk-kernels/releases) (kernels.zip)
- [ATK matrices](https://github.com/ambisonictoolkit/atk-matrices/releases) (matrices.zip)

Create/Open the ATK user support directory:

```supercollider
(
Atk.createUserSupportDir;
Atk.openUserSupportDir;
)
```

Now, extract the downloaded zip files and copy the `kernels` and
`matrices` directories into the support directory.
