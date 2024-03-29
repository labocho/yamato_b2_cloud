lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "yamato_b2_cloud/version"

# rubocop:disable Gemspec/RequiredRubyVersion
Gem::Specification.new do |spec|
  spec.name          = "yamato_b2_cloud"
  spec.version       = YamatoB2Cloud::VERSION
  spec.authors       = ["labocho"]
  spec.email         = ["labocho@penguinlab.jp"]

  spec.summary       = "CSV generator for Kuroneko Yamato B2 Cloud"
  spec.description   = "CSV generator for Kuroneko Yamato B2 Cloud"
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r(^exe/)) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0"

  spec.add_dependency "activemodel", ">= 5"
  spec.add_dependency "phonenumber_jp", "~> 0.1.2"
  spec.add_dependency "windows_31j_punctuation", "~> 0.1.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.76"
end
# rubocop:enable Gemspec/RequiredRubyVersion
