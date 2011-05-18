$:.unshift(File.dirname(__FILE__) + '/../lib/')
$:.unshift(File.dirname(__FILE__) + '/..')

require 'riot'
require 'riot-rack'
require 'app/libraries'

ENV['RACK_ENV'] = 'test'

