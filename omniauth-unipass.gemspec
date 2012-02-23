# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth/unipass/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Aleksadner Dąbrowski', 'Karol Sarnacki']
  gem.email         = ['aleksander.dabrowski@connectmedica.com', 'sodercober@gmail.com']
  gem.description   = %q{Unipass strategy for OmniAuth 1.0}
  gem.summary       = %q{Unipass strategy for OmniAuth 1.0}
  gem.homepage      = 'https://github.com/connectmedica/omniauth-unipass'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'omniauth-unipass'
  gem.require_paths = ['lib']
  gem.version       = Omniauth::Unipass::VERSION

  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.0.0'

  gem.add_development_dependency 'rspec', '~> 2.7.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'simplecov'
end
