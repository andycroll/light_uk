# Read fixtures from disk: pages captured from the Cambridge venue's website
# and trimmed to a few films. They follow the shape in api_shapes.rb.
module FixturesHelper
  private

  def home_html(cinema_id)
    read_fixture("website/home-#{cinema_id}.html")
  end

  def miniguide_js(cinema_id)
    read_fixture("website/miniguide-#{cinema_id}.js")
  end

  def coming_soon_html(cinema_id)
    read_fixture("website/coming-soon-#{cinema_id}.html")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
