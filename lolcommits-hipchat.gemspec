# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lolcommits/hipchat/version'

Gem::Specification.new do |spec|
  spec.name          = "lolcommits-hipchat"
  spec.version       = Lolcommits::Hipchat::VERSION
  spec.authors       = ["Matthew Hutchinson"]
  spec.email         = ["matt@hiddenloop.com"]
  spec.summary       = %q{Uploads lolcommits to a remote server}

  spec.description = <<-EOF
  Uploads lolcommits to a remote server, with optional key or  HTTP based
  authentication.
  EOF

  spec.homepage      = "https://github.com/lolcommits/lolcommits-hipchat"
  spec.license       = "LGPL-3"

  spec.metadata = {
    "homepage_uri"    => "https://github.com/lolcommits/lolcommits-hipchat",
    "changelog_uri"   => "https://github.com/lolcommits/lolcommits-hipchat/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/lolcommits/lolcommits-hipchat",
    "bug_tracker_uri" => "https://github.com/lolcommits/lolcommits-hipchat/issues",
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(assets|test|features)/}) }
  spec.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1"
  spec.add_runtime_dependency "mime-types"

  spec.add_development_dependency "lolcommits", ">= 0.12.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
end
