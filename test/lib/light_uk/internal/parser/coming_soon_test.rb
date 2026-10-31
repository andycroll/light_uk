require_relative '../../../../test_helper'

class LightUk::Internal::Parser::ComingSoonTest < Minitest::Test
  include FixturesHelper

  def test_films_with_their_sessions
    film = films.find { |f| f['ID'] == 20243 }

    assert_equal 'NT Live: Hay Fever', film['Title']
    assert_equal %w(20270114 20270117 20270121 20270401), film['Dates'].map { |date| date['Key'] }
    assert_equal '83239', film['Dates'].first['Sessions'].first['BOID']
  end

  def test_films_not_yet_on_sale_have_no_dates
    assert_equal [], films.find { |f| f['ID'] == 19363 }['Dates']
  end

  def test_titles_as_on_the_page
    assert_equal "It's A Wonderful Life (80th Anniversary) + Mulled Wine & Mince Pies",
                 films.find { |f| f['ID'] == 20445 }['Title']
  end

  def test_page_without_films
    assert_equal [], LightUk::Internal::Parser::ComingSoon.new('<html></html>').films
  end

  private

  def films
    LightUk::Internal::Parser::ComingSoon.new(coming_soon_html('3')).films
  end
end
