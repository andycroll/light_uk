require_relative '../../../test_helper'

class LightUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_anniversary_restoration
    assert_sanitized "Pan's Labyrinth", "Pan's Labyrinth (20th Anniversary 4K Restoration)"
    assert_sanitized 'Animal Farm', 'Animal Farm (4K Restoration)'
  end

  def test_removes_language_version
    assert_sanitized 'Traces of Justice', 'Traces of Justice (Mandarin)'
  end

  def test_removes_q_and_a
    assert_sanitized 'We, The Hated', 'We, The Hated + in person director Q&A'
  end

  def test_removes_extras
    assert_sanitized "It's A Wonderful Life", "It's A Wonderful Life (80th Anniversary) + Mulled Wine & Mince Pies"
    assert_sanitized 'The Rocky Horror Picture Show', 'Crafty Cinema: The Rocky Horror Picture Show'
  end

  def test_standardises_national_theatre_live
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
    assert_sanitized 'National Theatre Live: The Motive and the Cue', 'NT Live: The Motive and the Cue (Encore)'
    assert_sanitized 'National Theatre Live: Golden Boy', 'National Theatre Live: Golden Boy'
  end

  def test_standardises_event_cinema
    assert_sanitized 'Exhibition on Screen: Monet', 'EXHIBITION ON SCREEN: Monet'
    assert_sanitized 'Royal Ballet and Opera: Carmen', 'RBO Cinema Season 2026-27: Carmen'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'Ghosts: The Possession of Button House',
      'Mystery Screening 37',
      "We're Going on a Bear Hunt + The Tiger Who Came to Tea: double bill",
      'Blade Runner 2049'
    ].each { |title| assert_sanitized title, title }
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, LightUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
