Gem::Specification.new do |s|
  s.name = 'app-routes'
  s.version = '0.1.15'
  s.summary = 'app-routes'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb'] 
  s.signing_key = '../privatekeys/app-routes.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/app-routes'
end
