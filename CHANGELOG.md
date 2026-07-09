# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to
[Semantic Versioning].

## [Unreleased]

## [1.1.0] - 2026-07-09

### Added

- This changelog
- Module prefix is now passed through its `meta` attribute
  (c55943c5e8197cbc2d0e506693fd5e7e3ea0a0c3)
- New functions `lists.cartesian.product` and `lists.cartesian.map`
  (2af4e9f1d5dfe835c0eba15be1035bfa4065aca7)
- Documentation strings follow RFC 145 format and are shown by `:doc`
  in `nix repl` (#3)
- Experimental module-level assertions (#8)

### Fixed

- README formatting fixes (#12)
- Fixed usage of `or` as identifier, which is deprecated in Lix (#5)

## [1.0.1] - 2025-06-07

### Fixed

- Removed some unnecessary restrictions on type merging (#2)

## [1.0.0] - 2025-03-30

Initial release

[Unreleased]: https://git.auxolotl.org/auxolotl/lib/compare/v1.1.0...HEAD
[1.1.0]: https://git.auxolotl.org/auxolotl/lib/compare/v1.0.1...v1.1.0
[1.0.1]: https://git.auxolotl.org/auxolotl/lib/compare/v1.0.0...v1.0.1
[1.0.0]: https://git.auxolotl.org/auxolotl/lib/releases/tag/v1.0.0
[Keep a Changelog]: https://keepachangelog.com/en/1.1.0
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
