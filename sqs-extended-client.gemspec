# frozen_string_literal: true

require_relative "lib/sqs_extended_client/version"

Gem::Specification.new do |spec|
  spec.name = "sqs-extended-client"
  spec.version = SqsExtendedClient::VERSION
  spec.authors = ["Yuu Yamanoi"]
  spec.email = ["yuu.yamanoi1222@gmail.com"]

  spec.summary = ""
  spec.description = ""
  spec.homepage = "https://github.com/yyamanoi1222/sqs-ruby-extended-client"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk-s3", '~> 1'
  spec.add_dependency "aws-sdk-sqs", '~> 1'
  spec.add_dependency "nokogiri"
end
