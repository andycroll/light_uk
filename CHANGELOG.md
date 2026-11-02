# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- Requests retry dropped connections twice.
- HTTP errors read "HTTP error 500 from cambridge.thelight.co.uk" instead of "Light HTTP error 500".

## [1.0.0] - 2026-10-31

### Added
- `LightUk::Cinema.all` and `LightUk::Cinema.new(id)` for Light's cinemas, from the venue list on every venue's home page, with addresses and postcodes from each venue's page footer.
- `LightUk::Performance.at(id, from:, to:)`, from the venue's fortnight guide and its coming soon page, with booking links, variants, languages and film years from titles, and festivals, following cinebase 5.6.
- Fixtures trimmed from live pages, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
