# frozen_string_literal: true

require "json"

module LightUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads venues and listings from the Light websites, one per venue
    class Website
      # Every venue's home page lists all the venues
      SITES_URL = "https://sheffield.thelight.co.uk/"
      MINIGUIDE_PATH = "/resource/services/miniguide/data.ashx"
      COMING_SOON_PATH = "/cinema/comingsoon"

      def initialize
        @http = Cinebase::Http.new
      end

      # @return [Array<Hash>] venues, e.g. { 'id' => 7, 'title' => 'Sheffield',
      #   'url' => 'https://sheffield.thelight.co.uk' }
      def sites
        JSON.parse(@http.get(SITES_URL)[/var __sites = (\[.*?\]);/, 1] || "[]")
      end

      # @param [String] url a venue's home page
      # @return [String, nil] the address in the page footer, e.g.
      #   'The Moor, Sheffield, S1 4PF'
      def address(url)
        address = @http.get(url)[%r{<p class="address">(.*?)</p>}m, 1]
        CGI.unescapeHTML(address).strip if address
      end

      # The guide behind the venue's listings, which covers a fortnight
      # @param [String] url a venue's home page
      # @return [Array<Hash>] films with their sessions on each date
      def miniguide(url)
        script = @http.get(URI.join(url, MINIGUIDE_PATH).to_s)
        JSON.parse(script[/var __gfminiguidedata = (\{.*\});/m, 1] || "{}").fetch("Schedule", [])
      end

      # Every session of films not yet showing, however far ahead
      # @param [String] url a venue's home page
      # @return [Array<Hash>] films in the shape of #miniguide
      def coming_soon(url)
        Parser::ComingSoon.new(@http.get(URI.join(url, COMING_SOON_PATH).to_s)).films
      end
    end
  end
end
