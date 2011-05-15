# -*- coding: utf-8 -*-

class Profile < Sequel::Model
  plugin :timestamps, :update_on_create=>true

  one_to_many :items
  many_to_many :friends, :left_key => :jack_id, :right_key => :jill_id,
                         :join_table => :friends, :class => self

  def self.find_or_create(fbid)
    Profile.filter(:facebook_id => fbid).first || Profile.create(:facebook_id => fbid)
  end
end

class Item < Sequel::Model
  plugin :timestamps, :update_on_create=>true

  many_to_one :profile
  many_to_many :tags

  def self.find_by_token(t)
    Item.filter(:token => t).first
  end

  def self.to_buy
    Item.filter(:sold => false).filter(:deleted => false)
  end

  def self.find_nearby(lat, lon, range)
    Item.to_buy.filter('(acos(cos(?)*cos(?)*cos(latitude)*cos(longitude) + ' +
                '      cos(?)*sin(?)*cos(latitude)*sin(longitude) + ' +
                '      sin(?)*sin(latitude) ) * 6371000) <= ?', lat, lon, lat, lon, lat, range)
  end
end

class Tag < Sequel::Model
  many_to_many :items

  def self.find_or_create(tag)
    Tag.filter(:name => tag).first || Tag.create(:name => tag)
  end
end


# Spherical (simplest but least accurate)
# Vincenty (most accurate and most complicated)
# Haversine (somewhere inbetween).

# Graticule::Distance::Spherical.distance(
#   Graticule::Location.new(:latitude => 42.7654, :longitude => -86.1085),
#   Graticule::Location.new(:latitude => 41.849838, :longitude => -87.648193)
# )



#   self.raise_on_typecast_failure = false

#   # Timestamp JobOffers using +created_at+ and +updated_at+
#   # TODO: plugin :timestamps, :update_on_create=>true
#   # TODO: database migrate +created_at+ and +updated_at+

#   def self.find_by_token(token)
#     return if token.blank?
#     JobOffer.filter(:token => token).first
#   end

#   def before_create
#     super

#     if self.token.blank?
#       # Generate a unique token
#       token = ''
#       while token.blank? or JobOffer.find_by_token(token)
#         token = rand(36**12).to_s(36) while token.length < 8
#       end
#       self.token = token[0..7]
#     end
#   end

#   def validate
#     super
#     validates_presence :company_name
#     validates_presence :company_location
#     validates_presence :description
#     validates_presence :email_cv
#     validates_presence :email_recruiter
#     validates_presence :rewards
#     validates_presence :telecommute
#     validates_presence :title
#   end
# end

# class Talent < Sequel::Model
#   self.raise_on_typecast_failure = false

#   many_to_one :location

#   def self.find_by_token(token)
#     return if token.blank?
#     Talent.filter(:token => token).first
#   end

#   def before_create
#     super

#     if self.token.blank?
#       # Generate a unique token
#       token = ''
#       while token.blank? or Talent.find_by_token(token)
#         token = rand(36**12).to_s(36) while token.length < 8
#       end
#       self.token = token[0..7]
#     end
#   end

#   def email=(str)
#     str = str.downcase if str.respond_to? :downcase
#     super(str)
#   end

#   def validate
#     super
#     [:email, :willing_to_travel, :experience_level,
#      :experience_bio, :gold_star_bio, :skills, :location].each do |attr|
#       validates_presence attr
#     end

#     unless self.email =~ /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/
#       self.errors.add(:email, "invalid email")
#     end

#     # TODO: email has unique lowercase database constraint
#     # TODO: token has unique lowercase database constraint
#   end
# end

# class EmailJobOffer < Sequel::Model
# end
