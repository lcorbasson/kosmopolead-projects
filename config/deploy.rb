set :stages, %w(dev beta prod)
set :default_stage, "dev"
require 'capistrano/ext/multistage'
