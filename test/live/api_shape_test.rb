require_relative 'live_helper'

class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  CAMBRIDGE = 'https://cambridge.thelight.co.uk'.freeze

  def test_sites_are_readable
    assert_sites_shape(LightUk::Internal::Website.new.sites)
  end

  def test_address_is_readable
    assert_address_shape(LightUk::Internal::Website.new.address(CAMBRIDGE))
  end

  def test_miniguide_is_readable
    assert_films_shape(LightUk::Internal::Website.new.miniguide(CAMBRIDGE))
  end

  def test_coming_soon_is_readable
    assert_films_shape(LightUk::Internal::Website.new.coming_soon(CAMBRIDGE))
  end
end
