unless $LOAD_PATH.include? '.'
  $LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__))
end

require 'app/app'

run Sellastic::App.new
