# coding: utf-8
lib = File.expand_path('.', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "wrapper"
  spec.version       = 1
  spec.authors       = ["Shivam Saxena"]
  spec.email         = [""]

  spec.require_paths = ["."]

  spec.add_dependency 'omniauth', '~> 1.0'
  spec.add_dependency 'omniauth-oauth2', '~> 1.1'

end