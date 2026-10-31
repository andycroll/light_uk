# The parts of Light pages the gem reads. Checked against the trimmed
# fixtures and, in the live suite, against real pages held only in memory.
module ApiShapes
  private

  def assert_sites_shape(sites)
    refute_empty sites
    sites.each do |site|
      assert_kind_of Integer, site.fetch('id')
      assert_kind_of String, site.fetch('title')
      assert_match(%r{\Ahttps://[a-z]+\.thelight\.co\.uk\z}, site.fetch('url'))
    end
  end

  def assert_address_shape(address)
    assert_match(/, [A-Z]{1,2}\d[A-Z\d]? \d[A-Z]{2}\z/, address)
  end

  def assert_films_shape(films)
    refute_empty films
    films.each do |film|
      assert_kind_of Integer, film.fetch('ID')
      assert_kind_of String, film.fetch('Title')
      film.fetch('Dates').each do |date|
        assert_match(/\A\d{8}\z/, date.fetch('Key'))
        date.fetch('Sessions').each { |session| assert_session_shape(session) }
      end
    end
  end

  def assert_session_shape(session)
    assert_match(/\A\d+\z/, session['BOID']) if session.key?('BOID')
    assert_match(/\A\d{2}\.\d{2}\z/, session.fetch('Display'))
    assert_kind_of String, session.fetch('FormatDisplay')
    session.fetch('Collections').each { |collection| assert_kind_of String, collection.fetch('Title') }
  end
end
