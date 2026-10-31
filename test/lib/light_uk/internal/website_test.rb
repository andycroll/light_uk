require_relative '../../../test_helper'

class LightUk::Internal::WebsiteTest < Minitest::Test
  include FixturesHelper

  CAMBRIDGE = 'https://cambridge.thelight.co.uk'.freeze

  def test_sites_from_a_venue_home_page
    stub_request(:get, 'https://sheffield.thelight.co.uk/').to_return(status: 200, body: home_html('3'))

    site = website.sites.find { |s| s['id'] == 3 }

    assert_equal({ 'id' => 3, 'title' => 'Cambridge', 'url' => CAMBRIDGE }, site)
  end

  def test_address_from_home_page_footer
    stub_request(:get, CAMBRIDGE).to_return(status: 200, body: home_html('3'))

    assert_equal 'Cambridge Leisure Park, Clifton Way, Cambridge, CB1 7DY', website.address(CAMBRIDGE)
  end

  def test_address_missing
    stub_request(:get, CAMBRIDGE).to_return(status: 200, body: '<html></html>')

    assert_nil website.address(CAMBRIDGE)
  end

  def test_miniguide_reads_the_guide_script
    stub_request(:get, "#{CAMBRIDGE}/resource/services/miniguide/data.ashx")
      .to_return(status: 200, body: miniguide_js('3'))

    films = website.miniguide(CAMBRIDGE)

    assert_equal 6, films.size
    assert_equal 'The Rocky Horror Picture Show', films.first['Title']
  end

  def test_coming_soon_reads_the_page
    stub_request(:get, "#{CAMBRIDGE}/cinema/comingsoon").to_return(status: 200, body: coming_soon_html('3'))

    assert_equal [20293, 19685, 19363, 20445, 20243], website.coming_soon(CAMBRIDGE).map { |film| film['ID'] }
  end

  def test_errors_omit_body
    stub_request(:get, CAMBRIDGE).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { website.address(CAMBRIDGE) }

    assert_equal 'Light HTTP error 500', error.message
  end

  private

  def website
    LightUk::Internal::Website.new
  end
end
