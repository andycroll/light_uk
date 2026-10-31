require_relative '../../test_helper'

class LightUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil LightUk::VERSION
  end
end
