module LightUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [LightUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\ACrafty Cinema:\s*/i,                       # craft activity before the film
          /\s*\(\d+(st|nd|rd|th) Anniversary [^)]*\)/i, # anniversary restoration
          /\s*\(4K Restoration\)/i,                     # restoration
          /\s*\(Encore\)/i,                             # encore broadcast
          /\s*\+\s*Mulled Wine\b.*\z/i                  # seasonal extras
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /EXHIBITION ON SCREEN:\s*(.*)/i         => 'Exhibition on Screen: ',
          /(?:NT|National Theatre) Live:\s*(.*)/ => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
