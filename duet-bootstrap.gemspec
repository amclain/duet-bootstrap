version = File.read(File.expand_path('../version', __FILE__)).strip

Gem::Specification.new do |s|
  s.name      = 'duet-bootstrap'
  s.version   = version
  s.date      = Time.now.strftime '%Y-%m-%d'
  s.summary   = 'Generates a NetLinx workspace to load a Duet project.'
  s.description = 'This script generates a NetLinx workspace and source code to start up a Duet module. It is intended to be used when the entire AMX system has been programmed in Duet.'
  s.homepage  = 'https://sourceforge.net/p/duet-bootstrap/wiki/Home/'
  s.authors   = ['Alex McLain']
  s.email     = 'alex@alexmclain.com'
  s.license   = 'Apache 2.0'
  
  s.files     =
    ['license.txt', 'README.html'] +
    Dir['bin/**/*'] +
    Dir['lib/**/*'] +
    Dir['doc/**/*']
  
  s.executables = [
    'duet-bootstrap'
  ]
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('pry')
end
