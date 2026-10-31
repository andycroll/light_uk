# frozen_string_literal: true

require "json"

module LightUk
  # @api private
  module Internal
    module Parser
      # Reads the films and sessions embedded in a venue's coming soon page
      class ComingSoon
        # Each film's markup starts with its programme id
        FILM = /<div data-prog="(\d+)" class="prog">/
        TITLE = %r{<h2><a href="[^"]*">(.*?)</a></h2>}m

        # @param [String] html the coming soon page
        def initialize(html)
          @html = html
        end

        # @return [Array<Hash>] films in the shape of the miniguide's Schedule
        def films
          @html.split(FILM).drop(1).each_slice(2).filter_map do |id, markup|
            title = markup[TITLE, 1]
            dates = markup[/ScheduleBrowser\(\{selector: '#prog-#{id}'.*?, data:(\[.*?\])\}\)\}\);<\/script>/m, 1]
            if title && dates
              { "ID" => id.to_i, "Title" => title, "Dates" => JSON.parse(dates) }
            end
          end
        end
      end
    end
  end
end
