require_relative '../../../../test_helper'

class LightUk::Internal::Parser::SessionTest < Minitest::Test
  def test_to_hash
    expected = {
      booking_url: 'https://cambridge.thelight.co.uk/#!book/cinema/95292',
      dimension: '2d',
      festival: nil,
      film_name: 'From Dusk Till Dawn',
      film_year: 1996,
      language: nil,
      starting_at: Time.utc(2026, 7, 24, 17, 15),
      variant: []
    }

    assert_equal expected, parse
  end

  def test_london_winter_time
    assert_equal Time.utc(2026, 12, 24, 18, 15), parse(date: '20261224')[:starting_at]
  end

  def test_maps_collections_to_variants
    collections = ['Audio Description', 'Silver Screen', 'Frights at the Light', '15 Certificate', 'Toddler Time']

    assert_equal %w(audio_described senior kids), parse(collections: collections)[:variant]
  end

  def test_imax_3d
    hash = parse(format: 'IMAX 3D', collections: ['IMAX', '3D'])

    assert_equal '3d', hash[:dimension]
    assert_equal %w(imax), hash[:variant]
  end

  def test_language_from_title
    assert_equal 'Hindi', parse(title: 'Ramayana: Rise of a Legend (Hindi)')[:language]
  end

  def test_unescapes_title
    assert_equal 'Stray Kids World Tour <RUN IT> Live Viewing',
                 parse(title: 'Stray Kids World Tour &lt;RUN IT&gt; Live Viewing')[:film_name]
  end

  def test_session_that_has_started
    assert_nil parse(booking_id: nil)[:booking_url]
  end

  private

  def parse(booking_id: '95292', collections: [], date: '20260724', format: '2D', title: 'From Dusk Till Dawn (1996)')
    session = {
      'Collections' => collections.map { |name| { 'ID' => 1, 'Title' => name } },
      'Display' => '18.15',
      'FormatDisplay' => format
    }
    session['BOID'] = booking_id if booking_id
    LightUk::Internal::Parser::Session.new(
      session, film: { 'Title' => title }, date: { 'Key' => date }, venue_url: 'https://cambridge.thelight.co.uk'
    ).to_hash
  end
end
