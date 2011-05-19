# in memory database
# DB = Sequel.sqlite

case RACK_ENV
when 'production'
  DB = Sequel.postgres('sellastic_production', :user => 'sellastic', :password => 's3ll4stic', :host => 'localhost')
when 'development'
  DB = Sequel.postgres('sellastic_development', :user => 'sellastic', :host => 'localhost')
when 'test'
  DB = nil
  DB = Sequel.postgres('sellastic_test', :user => 'sellastic', :host => 'localhost')
  # TODO: setup testing transactions or database-cleaner
else
  DB = nil
end

#
# Sequel Plugins
#

# Enable validations
Sequel::Model.plugin :validation_helpers

# Force all strings to be UTF8 encoded in a all model subclasses
Sequel::Model.plugin :force_encoding, 'UTF-8'

# Make all model subclass instances strip strings (called before loading subclasses)
Sequel::Model.plugin :string_stripper
