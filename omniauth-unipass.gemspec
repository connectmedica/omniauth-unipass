require File.expand_path('../lib/omniauth-unipass/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Aleksadner Dąbrowski', 'Karol Sarnacki']
  gem.email         = ['aleksander.dabrowski@connectmedica.com', 'karol.sarnacki@connectmedica.pl']
  gem.description   = 'OmniAuth strategy for Unipass'
  gem.summary       = 'OmniAuth strategy for Unipass'
  gem.homepage      = 'https://github.com/tjeden/omniauth-unipass'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'omniauth-unipass'
  gem.require_paths = ['lib']
  gem.version       = OmniAuth::Unipass::VERSION

  gem.add_dependency 'omniauth', '0.3.0'
  gem.add_dependency 'multi_json'
end
