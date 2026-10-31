module LightUk
  # The object representing a cinema on the Light website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the Light id of the cinema, e.g. '7'

    # Worker processes outlive a day's listings, so refetch the venue list
    CACHE_SECONDS = 3600

    # UK postcode, the last part of an address
    POSTCODE = /\A[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}\z/i.freeze

    # Constructor
    # @param [Integer, String] id the cinema id of the format 7/'7'
    # @return [LightUk::Cinema]
    def initialize(id)
      @id = id.to_s
    end

    # Return basic cinema information for all cinemas
    # @return [Array<LightUk::Cinema>]
    # @example
    #   LightUk::Cinema.all
    #   #=> [<LightUk::Cinema>, <LightUk::Cinema>, ...]
    def self.all
      sites_hash.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema, read from the footer of its home page
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = LightUk::Cinema.new(3)
    #   cinema.adr
    #   #=> {
    #         street_address:   'Cambridge Leisure Park',
    #         extended_address: 'Clifton Way',
    #         locality:         'Cambridge',
    #         region:           nil,
    #         postal_code:      'CB1 7DY',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      parts = address_parts
      postal_code = parts.pop if parts.last&.match?(POSTCODE)
      # Some addresses leave out the town, which every venue is named after
      town_at = parts.index(name) || parts.size
      lines = parts.first(town_at)
      region = parts.drop(town_at + 1)
      {
        street_address:   lines.shift,
        extended_address: lines.empty? ? nil : lines.join(', '),
        locality:         name,
        region:           region.empty? ? nil : region.join(', '),
        postal_code:      postal_code,
        country_name:     'United Kingdom'.freeze
      }
    end

    # Brand of the cinema
    # @return [String] which will always be 'Light'
    def brand
      'Light'.freeze
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   LightUk::Cinema.new(7).name
    #   #=> 'Sheffield'
    def name
      site['title'].to_s
    end

    # The url of the cinema's home page on the Light website
    # @return [String]
    # @example
    #   LightUk::Cinema.new(7).url
    #   #=> 'https://sheffield.thelight.co.uk'
    def url
      site['url'].to_s
    end

    # @api private
    def self.sites_hash
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      if @sites_hash.nil? || now - @fetched_at > CACHE_SECONDS
        @fetched_at = now
        @sites_hash = LightUk::Internal::Website.new.sites.to_h { |site| [site.fetch('id').to_s, site] }
      end
      @sites_hash
    end
    private_class_method :sites_hash

    private

    def address_parts
      @address ||= LightUk::Internal::Website.new.address(url).to_s
      @address.split(',').map(&:strip).reject(&:empty?)
    end

    def site
      self.class.send(:sites_hash).fetch(id, {})
    end
  end
end
