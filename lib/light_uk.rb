require 'cgi/escape'
require 'json'

require 'cinebase'

require_relative './light_uk/version'

require_relative './light_uk/internal/http'
require_relative './light_uk/internal/website'
require_relative './light_uk/internal/title_sanitizer'

require_relative './light_uk/internal/parser/coming_soon'
require_relative './light_uk/internal/parser/session'

require_relative './light_uk/cinema'
require_relative './light_uk/performance'

# light_uk gem
module LightUk
end
