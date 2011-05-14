RACK_ENV  = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
RACK_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

## std lib
require 'ostruct'

# require 'open3'
# require 'uri'
# require 'base64'
# require 'digest'
# require 'zlib'
# require "rexml/document"

# bundled gems
require 'sinatra/base'
require 'sequel'
require 'yajl'
require 'pony'
require 'erubis'
Tilt.register :erb, Tilt[:erubis]
require 'sinatra/content_for2'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# sellastic
require 'helpers'

require 'models/db'
require 'models/models'
