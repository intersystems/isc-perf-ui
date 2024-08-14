# isc.perf.ui

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.0.0] - Unreleased

### Added 
- New home tab allowing the user to run and see the results of TestCoverage on their unit tests
- New historical coverage tab showing class level results for past TestCoverage runs 

### Changed
- Authentication now uses standard IRIS Login

### Fixed
- Fixed handling for authentication headers to suppress the browser's credential prompts
- Fixed export behavior when developing with git-source-control and a modern IPM version
- Updated documentation around node/npm requirement

### Security
- Bumped various dependency versions

## [1.0.1] - 2022-06-21
### Fixed
- Works around issue with empty CSS files and zpm/zpm-registry (fixes installation from remote registry)

## [1.0.0] - 2022-06-21
- First released version

