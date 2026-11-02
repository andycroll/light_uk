# frozen_string_literal: true

module LightUk
  # @api private
  module Internal
    module Parser
      # Parses a single Light session into performance attributes
      class Session
        # Booking opens in a panel on the venue's home page
        BOOKING_PATH = "/#!book/cinema/"

        # Light collection titles
        VARIANTS = {
          "Audio Description" => "audio_described",
          "Baby-friendly screenings" => "baby",
          "Captioned for hard of hearing" => "subtitled",
          "Dementia-friendly screenings" => "relaxed",
          "Family Specials" => "kids",
          "IMAX" => "imax",
          "Museums & Galleries on Screen" => "arts",
          "Music" => "arts",
          "Musicals" => "arts",
          "Opera & Dance" => "arts",
          "Q&A" => "q&a",
          "Relaxed Screenings" => "relaxed",
          "Silver Screen" => "senior",
          "Theatre" => "arts",
          "Toddler Time" => "kids"
        }.freeze

        # FormatDisplay, e.g. '2D', '3D', 'IMAX' or 'IMAX 3D'
        THREE_D = /\b3D\b/i
        IMAX = /\bIMAX\b/i

        LANGUAGE = /\((#{Cinebase::TitleSanitizer::LANGUAGES.join('|')})\)/i

        # @param [Hash] session one session
        # @param [Hash] film the film the session shows
        # @param [Hash] date the listings date the session is on
        # @param [String] venue_url the venue's home page
        def initialize(session, film:, date:, venue_url:)
          @session = session
          @film = film
          @date = date
          @venue_url = venue_url
        end

        # @return [Hash] options for LightUk::Performance.new
        def to_hash
          {
            booking_url: booking_url,
            dimension: format.match?(THREE_D) ? "3d" : "2d",
            festival: Cinebase::Festival.from_title(title, year: starting_at.year),
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(title),
            language: title[LANGUAGE, 1],
            starting_at: starting_at,
            variant: variant
          }
        end

        private

        # Sessions that have started have no booking id
        def booking_url
          id = @session["BOID"]
          "#{@venue_url.chomp('/')}#{BOOKING_PATH}#{id}" if id
        end

        def format
          @session["FormatDisplay"].to_s
        end

        # Dates are keys such as '20261031' and times are London time such as '18.15'
        def starting_at
          @starting_at ||= begin
            year, month, day = @date.fetch("Key").unpack("a4a2a2").map(&:to_i)
            hour, minute = @session.fetch("Display").scan(/\d+/).map(&:to_i)
            local = Time.utc(year, month, day, hour, minute)
            Cinebase::London.utc(local)
          end
        end

        def title
          @title ||= CGI.unescapeHTML(@film.fetch("Title"))
        end

        def variant
          variants = @session.fetch("Collections", []).filter_map { |collection| VARIANTS[collection["Title"]] }
          variants << "imax" if format.match?(IMAX)
          variants.uniq
        end
      end
    end
  end
end
