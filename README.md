# LightUk

A simple gem to pull cinemas and performances from the [Light cinemas website](https://thelight.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'light_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install light_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing language
versions, years, anniversary restorations, Q&A add-ons and festival prefixes.

No token or setup is needed. Each venue has its own site, such as
`https://sheffield.thelight.co.uk`, built by Glitterfish. Every venue's home
page lists all the venues and shows its own address.

### Cinema

The venue list is cached for an hour. The first call to an address method reads
the cinema's home page. The website gives no coordinates, so `latitude` and
`longitude` are `nil`.

``` ruby
LightUk::Cinema.all
#=> [<LightUk::Cinema ...>, <LightUk::Cinema ...>, ...]

cinema = LightUk::Cinema.new(3)
#=> <LightUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Cambridge Leisure Park',
  extended_address: 'Clifton Way',
  locality:         'Cambridge',
  region:           nil,
  postal_code:      'CB1 7DY',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Light'

cinema.full_name
#=> 'Light Cambridge'

cinema.id
#=> '3'

cinema.url
#=> 'https://cambridge.thelight.co.uk'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The venue's guide only
covers a fortnight, so it also reads the coming soon page, which holds every
session of films that have not opened yet, however far ahead. That is two
requests for all of the cinema's advertised dates.

``` ruby
LightUk::Performance.at(3, from: Date.today, to: Date.today + 2)
#=> [<LightUk::Performance ...>, <LightUk::Performance ...>, ...]

performance = LightUk::Performance.at(3).first
#=> <LightUk::Performance ...>

performance.film_name
#=> 'Ramayana: Rise of a Legend'

performance.language
#=> 'Hindi' # from '(Hindi)' in the title

performance.film_year
#=> nil # from the title, e.g. 1996 for 'From Dusk Till Dawn (1996)'

performance.dimension
#=> '3d'

performance.variant
#=> ['imax']

performance.subtitled?
#=> false

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="CFF", year=2026>

performance.starting_at
#=> 2026-11-08 19:50:00 UTC

performance.booking_url
#=> 'https://cambridge.thelight.co.uk/#!book/cinema/83478'

performance.cinema_name
#=> 'Cambridge'

performance.cinema_id
#=> '3'
```

Booking links open the booking panel on the venue's home page. Sessions that
have started have no booking link.

Variants are `arts`, `audio_described`, `baby`, `imax`, `kids`, `q&a`,
`relaxed`, `senior` and `subtitled`.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live thelight.co.uk
```

Fixtures in `test/fixtures` are pages captured from the Cambridge venue's
website and trimmed to a few films. `test/support/api_shapes.rb` describes the
fields the gem reads. The unit suite checks the fixtures against it and the
live suite checks real responses, held only in memory. When the website
changes, update the shape first, then the fixtures.

The website's certificate chains to Sectigo's Public Server Authentication Root
R46. Trust stores without it, such as macOS's `/etc/ssl/cert.pem`, fail to
verify it; point `SSL_CERT_FILE` at a current Mozilla bundle instead.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
