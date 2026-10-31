require_relative '../../test_helper'

class LightUk::PerformanceTest < Minitest::Test
  DATE = Date.new(2026, 11, 1)

  def setup
    @website = FakeWebsite.new
    LightUk::Cinema.instance_variable_set(:@sites_hash, nil)
  end

  def test_at_returns_performances_on_the_requested_date_only
    performances = performances_at(3)

    assert(performances.all? { |p| p.instance_of?(LightUk::Performance) })
    assert_equal 5, performances.count
    assert_equal [DATE], performances.map { |p| p.starting_at.to_date }.uniq
  end

  def test_at_accepts_string_id
    assert_equal 5, performances_at('3').count
  end

  def test_at_sets_cinema_details
    performances = performances_at(3)

    assert_equal ['3'], performances.map(&:cinema_id).uniq
    assert_equal ['Cambridge'], performances.map(&:cinema_name).uniq
  end

  def test_at_sorts_by_start
    performances = performances_at(3)

    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_parses_first_performance
    performance = performances_at(3).first

    assert_equal 'Wicker', performance.film_name
    assert_equal Time.utc(2026, 11, 1, 11, 45), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(subtitled), performance.variant
    assert_equal 'https://cambridge.thelight.co.uk/#!book/cinema/83080', performance.booking_url
  end

  def test_at_parses_imax
    performance = performances_at(3).find { |p| p.film_name == 'The Odyssey' }

    assert_equal %w(audio_described imax), performance.variant
  end

  def test_at_unescapes_titles
    assert_includes performances_at(3).map(&:film_name), "Pan's Labyrinth"
  end

  def test_at_includes_sessions_that_have_started_without_booking_url
    performance = with_fake_website { LightUk::Performance.at(3, from: DATE - 1, to: DATE - 1) }.first

    assert_equal 'The Rocky Horror Picture Show', performance.film_name
    assert_nil performance.booking_url
  end

  def test_at_reads_language_and_3d_from_the_guide
    performances = with_fake_website { LightUk::Performance.at(3, from: Date.new(2026, 11, 8), to: Date.new(2026, 11, 8)) }
    imax_3d = performances.find { |p| p.booking_url.end_with?('/83478') }

    assert_equal 'Ramayana: Rise of a Legend', imax_3d.film_name
    assert_equal 'Hindi', imax_3d.language
    assert_equal '3d', imax_3d.dimension
    assert_equal %w(imax), imax_3d.variant
  end

  def test_at_adds_coming_soon_beyond_the_guide
    performances = with_fake_website { LightUk::Performance.at(3, from: DATE, to: DATE + 365) }

    assert_includes performances.map(&:film_name), 'National Theatre Live: Hay Fever'
    assert_equal Time.utc(2027, 4, 1, 18), performances.last.starting_at
  end

  def test_at_lists_sessions_in_both_the_guide_and_coming_soon_once
    performances = with_fake_website { LightUk::Performance.at(3, from: DATE, to: DATE + 365) }
    booking_urls = performances.map(&:booking_url)

    assert_equal booking_urls.uniq, booking_urls
    assert_equal 12, performances.count { |p| p.film_name == 'Ramayana: Rise of a Legend' }
    assert_equal 4, performances.count { |p| p.film_name == 'National Theatre Live: Golden Boy' }
  end

  def test_at_makes_two_requests_for_every_date
    with_fake_website { LightUk::Performance.at(3, from: DATE, to: DATE + 365) }

    assert_equal 2, @website.requests
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { LightUk::Performance.at(3, from: DATE, to: DATE - 1) }
  end

  def test_new_sets_defaults
    performance = LightUk::Performance.new(
      film_name: 'Carol', cinema_id: '3', cinema_name: 'Cambridge',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    assert_nil performance.language
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def performances_at(cinema_id)
    with_fake_website { LightUk::Performance.at(cinema_id, from: DATE, to: DATE) }
  end

  def with_fake_website(&block)
    LightUk::Internal::Website.stub(:new, @website, &block)
  end
end
