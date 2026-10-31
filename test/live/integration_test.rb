require_relative 'live_helper'

class LiveCinemaTest < Minitest::Test
  def test_all_returns_cinemas
    cinemas = LightUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(LightUk::Cinema) })
    assert_operator cinemas.size, :>, 10
    assert_equal 'Cambridge', cinemas.detect { |cinema| cinema.id == '3' }.name
  end

  def test_address_has_a_postcode
    assert_equal 'CB1 7DY', LightUk::Cinema.new(3).postal_code
  end
end

class LivePerformanceTest < Minitest::Test
  def test_at_returns_performances
    tomorrow = Date.today + 1
    performances = LightUk::Performance.at(3, from: tomorrow, to: tomorrow)

    assert(performances.all? { |p| p.instance_of?(LightUk::Performance) })
    assert_operator performances.count, :>, 5
  end

  def test_at_reaches_beyond_the_fortnight
    today = Date.today
    performances = LightUk::Performance.at(3, from: today, to: today + 365)

    assert_operator performances.map(&:showing_on).max, :>, today + 14
  end
end
