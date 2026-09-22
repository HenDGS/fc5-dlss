# Changelog

## v1.1.0

- Added native HDR10/PQ support to the DLSS and DLAA paths.
- Added RCAS post-reconstruction sharpening with a saved strength control;
  the default is 0.50 and 0 disables it.
- Added automatic texture mip LOD bias based on the active render scale.
- Kept shadow/depth comparison and UI/post-process samplers unchanged by the
  automatic mip-bias feature.
- Clarified the optional RemoteDataProvider worker control, its privacy/CPU-time
  purpose, validation behavior and risks.
- Updated DLSS to version 310.9.1.0.

## v1.0.1

- Added DLSS/DLAA support for the alternate temporal-resolve permutation used
  while aiming through several weapon sights.

## v1.0.0

- Initial release with DLSS Super Resolution, DLAA, native TAA fallback,
  borderless scRGB HDR/RenoDX compatibility, Special K compatibility and the
  optional gameplay-reporting worker control.
