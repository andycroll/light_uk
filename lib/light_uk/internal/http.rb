# frozen_string_literal: true

require "net/http"

module LightUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to thelight.co.uk
    module Http
      private

      def get(url)
        uri = URI(url)
        request = Net::HTTP::Get.new(uri)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                       open_timeout: 10, read_timeout: 30) do |http|
          http.request(request)
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "Light HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end
    end
  end
end
