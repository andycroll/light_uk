require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  CAMBRIDGE = FakeWebsite::CAMBRIDGE

  def test_sites_fixture_matches_shape
    assert_sites_shape(FakeWebsite.new.sites)
  end

  def test_address_fixture_matches_shape
    assert_address_shape(FakeWebsite.new.address(CAMBRIDGE))
  end

  def test_miniguide_fixture_matches_shape
    assert_films_shape(FakeWebsite.new.miniguide(CAMBRIDGE))
  end

  def test_coming_soon_fixture_matches_shape
    assert_films_shape(FakeWebsite.new.coming_soon(CAMBRIDGE))
  end
end
