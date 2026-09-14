# Far Cry 5 DLSS / DLAA

Adds NVIDIA DLSS Super Resolution and DLAA to Far Cry 5 through
[Luma Framework](https://github.com/Filoppi/Luma-Framework). It replaces the
game's temporal anti-aliasing resolve while retaining native TAA as a safe fallback.

The mod also provides an optional borderless path for Far Cry 5's native scRGB HDR.
[RenoDX](https://github.com/clshortfuse/renodx) is recommended for improved HDR
tonemapping and color processing, but is not required for DLSS or DLAA.

## Requirements

- Windows and the DirectX 11 version of Far Cry 5.
- An NVIDIA RTX graphics card with DLSS support.
- [ReShade](https://reshade.me/) installed with full add-on support.
- In-game anti-aliasing set to **TAA** and dynamic resolution disabled.

## Installation

1. Install ReShade with full add-on support for `Far Cry 5\bin\FarCry5.exe`.
   Select the DirectX 10/11/12 renderer when prompted.
2. Download `Far-Cry-5-DLSS-v1.0.0.zip` from the latest GitHub release.
3. Close the game. If `bin\Luma-FarCry5.addon64` or `bin\nvngx_dlss.dll`
   already exists, back it up before continuing.
4. Extract the ZIP into the main **Far Cry 5** folder. Allow it to merge the
   included `bin` folder. The addon should end up at
   `Far Cry 5\bin\Luma-FarCry5.addon64`.
5. Launch the game and press **Home** to open ReShade. Open the **Luma** tab and
   leave Super Resolution on **Auto** or select **DLSS**.
6. Keep **Enable DLSS / DLAA** and **Match display resolution** enabled.

The game's **Resolution Scale** controls the mode:

- **100%:** DLAA at the output resolution.
- **Below 100%:** DLSS upscaling to the selected display resolution.

The 70% and 50% scale options are useful starting points. They are render scales,
not exact NVIDIA Quality/Balanced/Performance labels.

## Borderless HDR with RenoDX

For the best HDR presentation, install the Far Cry 5 RenoDX addon separately and:

1. Enable Windows HDR and disable Windows Auto HDR for Far Cry 5.
2. In Luma, enable **Borderless HDR / RenoDX** and restart the game.
3. In **Options > Video > Monitor**, choose **Fullscreen**, the display's native
   resolution and refresh rate, then select **HDR scRGB**.

Far Cry 5 must be set to Fullscreen for its native HDR option to remain available.
Luma prevents actual exclusive fullscreen and presents the native scRGB output in a
borderless window. Selecting Borderless in the game menu disables its HDR selector.

Use **HDR scRGB**. The HDR10/PQ path is not supported by the DLSS integration and
falls back to the game's native TAA.

## Special K compatibility

Special K 26.8.12 was tested successfully through global injection. Keep ReShade as
`bin\dxgi.dll`; do not replace it with a local Special K proxy. Before launching the
game, set this in Far Cry 5's Special K profile:

```ini
[SpecialK.System]
GlobalInjectDelay=10.0
```

The delay is the compatibility workaround. Immediate injection can crash during
Special K's NVIDIA HDR initialization. Disabling NVIDIA HDR support is not a valid
alternative because it breaks the intended HDR/DLSS path.

## Optional reporting-thread control

Luma can suspend a verified Far Cry 5 gameplay-reporting worker. The choice is saved
across launches and defaults to off. Luma validates the supported game code and the
live thread before suspending it; it never stores a thread ID between launches.

This option may interfere with gameplay reporting or hang the game. If the overlay
cannot be reopened, close the game and set `FC5SuspendReporter=0` under `[Luma]` in
`bin\ReShade.ini`. The UI reports whether the worker is actually suspended.

## Limitations

- Tested on an RTX 4090; other GPUs and game executable revisions have not been verified.
- Depth of field and motion blur have not received dedicated temporal-artifact tests.
- HDR10/PQ is unsupported by the DLSS path; use SDR or HDR scRGB.
- Dynamic resolution is unsupported. Change the static Resolution Scale instead.
- Cutscenes, vehicles, camera transitions, menus, ADS and several hours of normal
  gameplay have worked in testing, but every mission and edge case is not covered.
- Multiple simultaneous injectors can be order-sensitive. Only the documented
  ReShade, RenoDX and delayed Special K arrangement has been tested.

If DLSS inputs are missing or invalid, the mod retains Far Cry 5's native TAA for
that frame instead of presenting an incomplete DLSS result.

## Uninstallation

Close the game, then remove `bin\Luma-FarCry5.addon64`, the
`bin\Luma\Far Cry 5` shader folder, and `bin\nvngx_dlss.dll` only if that runtime
was installed by this mod. Restore any files you backed up during installation. Do not remove
`dxgi.dll`, RenoDX, other ReShade addons, or shared shader folders unless you know
they were installed only for this mod.

## Building from source

Visual Studio 2022 C++ tools and Windows SDK 10.0.26100 are required.

```powershell
git clone --recurse-submodules https://github.com/HenDGS/fc5-dlss.git
cd fc5-dlss
./build.ps1
```

`bootstrap.ps1` pins Luma Framework, applies the small FC5 framework patch, and
copies the FC5 source/shader overlay into the upstream tree. `package.ps1` produces
the distributable ZIP. These scripts never install files into the game directory.

## Credits

- **HenDGS** — Far Cry 5 integration.
- **Filippo Tarpini and contributors** — Luma Framework.
- **Musa Haji and RenoDX contributors** — Far Cry 5 shader reference and HDR work.
- **crosire and contributors** — ReShade.
- **NVIDIA** — DLSS / NGX.

Far Cry 5 and Dunia are properties of Ubisoft. This project is not affiliated with
or endorsed by Ubisoft or NVIDIA. See [LICENSE.md](LICENSE.md) and
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
