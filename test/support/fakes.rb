require_relative 'fixtures_helper'

class FakeWebsite
  include FixturesHelper

  CAMBRIDGE = 'https://cambridge.thelight.co.uk'.freeze

  attr_reader :requests

  def initialize
    @requests = 0
  end

  def sites
    JSON.parse(home_html('3')[/var __sites = (\[.*?\]);/, 1])
  end

  def address(url)
    home_html(fixture_id(url))[%r{<p class="address">(.*?)</p>}, 1]
  end

  def miniguide(url)
    @requests += 1
    JSON.parse(miniguide_js(fixture_id(url))[/var __gfminiguidedata = (\{.*\});/m, 1]).fetch('Schedule')
  end

  def coming_soon(url)
    @requests += 1
    LightUk::Internal::Parser::ComingSoon.new(coming_soon_html(fixture_id(url))).films
  end

  private

  def fixture_id(url)
    url == CAMBRIDGE ? '3' : (raise "No fixture for #{url}")
  end
end
