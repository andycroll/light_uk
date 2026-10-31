require_relative '../../test_helper'

class LightUk::CinemaTest < Minitest::Test
  def setup
    @website = FakeWebsite.new
    LightUk::Cinema.instance_variable_set(:@sites_hash, nil)
  end

  def test_new_stores_string_id
    assert_equal '3', LightUk::Cinema.new(3).id
  end

  def test_all_returns_every_venue
    with_fake_website do
      cinemas = LightUk::Cinema.all

      assert(cinemas.all? { |cinema| cinema.instance_of?(LightUk::Cinema) })
      assert_equal 14, cinemas.size
      assert_includes cinemas.map(&:id), '3'
    end
  end

  def test_all_reuses_the_venue_list
    calls = 0
    website = Object.new
    website.define_singleton_method(:sites) do
      calls += 1
      [{ 'id' => 3, 'title' => 'Cambridge', 'url' => 'https://cambridge.thelight.co.uk' }]
    end

    LightUk::Internal::Website.stub(:new, website) do
      LightUk::Cinema.all
      LightUk::Cinema.new(3).name
    end

    assert_equal 1, calls
  end

  def test_all_refetches_the_venue_list_after_an_hour
    calls = 0
    website = Object.new
    website.define_singleton_method(:sites) do
      calls += 1
      []
    end

    LightUk::Internal::Website.stub(:new, website) do
      Process.stub(:clock_gettime, 0) { LightUk::Cinema.all }
      Process.stub(:clock_gettime, LightUk::Cinema::CACHE_SECONDS + 1) { LightUk::Cinema.all }
    end

    assert_equal 2, calls
  end

  def test_name_and_full_name
    with_fake_website do
      assert_equal 'Cambridge', LightUk::Cinema.new(3).name
      assert_equal 'Light New Brighton', LightUk::Cinema.new('1').full_name
    end
  end

  def test_brand
    assert_equal 'Light', LightUk::Cinema.new(3).brand
  end

  def test_slug
    with_fake_website do
      assert_equal 'light-new-brighton', LightUk::Cinema.new(1).slug
    end
  end

  def test_url
    with_fake_website do
      assert_equal 'https://cambridge.thelight.co.uk', LightUk::Cinema.new(3).url
    end
  end

  def test_no_coordinates
    assert_nil LightUk::Cinema.new(3).latitude
    assert_nil LightUk::Cinema.new(3).longitude
  end

  def test_adr_from_home_page
    expected = {
      street_address:   'Cambridge Leisure Park',
      extended_address: 'Clifton Way',
      locality:         'Cambridge',
      region:           nil,
      postal_code:      'CB1 7DY',
      country_name:     'United Kingdom'
    }

    with_fake_website do
      assert_equal expected, LightUk::Cinema.new(3).adr
      assert_equal 'CB1 7DY', LightUk::Cinema.new(3).postal_code
    end
  end

  def test_adr_with_county_after_town
    adr = adr_for('Banbury', 'Spiceball Park Road, Banbury, Oxfordshire, OX16 2PA')

    assert_equal 'Spiceball Park Road', adr[:street_address]
    assert_nil adr[:extended_address]
    assert_equal 'Banbury', adr[:locality]
    assert_equal 'Oxfordshire', adr[:region]
    assert_equal 'OX16 2PA', adr[:postal_code]
  end

  def test_adr_without_town
    adr = adr_for('Addlestone', 'Addlestone One, KT15 2GN')

    assert_equal 'Addlestone One', adr[:street_address]
    assert_equal 'Addlestone', adr[:locality]
    assert_equal 'KT15 2GN', adr[:postal_code]
  end

  def test_adr_without_address
    adr = adr_for('Cambridge', nil)

    assert_nil adr[:street_address]
    assert_nil adr[:postal_code]
    assert_equal 'Cambridge', adr[:locality]
  end

  private

  def adr_for(name, address)
    website = Object.new
    website.define_singleton_method(:sites) { [{ 'id' => 3, 'title' => name, 'url' => 'https://example.thelight.co.uk' }] }
    website.define_singleton_method(:address) { |_url| address }

    LightUk::Internal::Website.stub(:new, website) { LightUk::Cinema.new(3).adr }
  end

  def with_fake_website(&block)
    LightUk::Internal::Website.stub(:new, @website, &block)
  end
end
