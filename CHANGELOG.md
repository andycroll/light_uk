# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
- `LightUk::Cinema.all` and `LightUk::Cinema.new(id)` for Light's cinemas, from the venue list on every venue's home page, with addresses and postcodes from each venue's page footer.
- `LightUk::Performance.at(id, from:, to:)`, from the venue's fortnight guide and its coming soon page, with booking links, variants, languages and film years from titles, and festivals, following cinebase 5.6.
- Fixtures trimmed from live pages, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
