# -*- coding: utf-8 -*-
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class Hash
  # Clean up a hash (eg. params) to only include keys you want.
  #
  # See: http://stackoverflow.com/questions/5652976/slicing-params-hash-for-specific-values
  #
  #   Example:
  #     {a:2, b:3, c:1}.slice(:a,:b,:d)
  #     => {:a=>2, :b=>3, :d=>nil}
  #
  def slice(*keys)
    h = {}
    keys.each{|k| h[k] = self[k]}
    h
  end
end

module Sellastic
  module Helpers

    #
    # helpers defined here are available to all views and sinatra routes
    #

    def translate_pl(msg)
      case msg
      when 'is not present'
        "nie może być puste"
      when 'invalid email'
        "nie jest prawidłowy email"
      else
        msg
      end
    end

    def page_title
      title = "Sellastic.com"
    end

    def html_new_lines(content)
      content.gsub(/\n/, '<br>')
    end

    def link_to(thing, title, opts = {})
      if opts.key?(:class)
        "<a href=\"#{url_for(thing)}\" class=\"#{opts[:class]}\">#{title.to_s}</a>"
      else
        "<a href=\"#{url_for(thing)}\">#{title.to_s}</a>"
      end
    end

    def error_div(errors)
      return '' if errors.blank?
      s = '<div class="error">'
      s << translate_pl(errors.first)
      s << '</div>'
    end

    # def url_for(thing)
    #   case thing
    #   when 'new_talent'
    #     '/informatyk/rejestracja'
    #   when 'new_talent_thanks'
    #     '/witamy'
    #   when JobOffer
    #     "/praca/oferta/#{thing.token}"
    #   else
    #     raise ArgumentError, "No url_for #{thing}"
    #   end
    # end

    # def send_email_praca(whom, subject, message)
    #   if [whom, subject, message].any? { |x| not (x.kind_of? String) }
    #     raise ArgumentError, 'Expected a string'
    #   end
    #   Pony.mail(:from => 'praca@1000it.pl',
    #             :to   => whom,
    #             :subject => subject,
    #             :body    => message,
    #             :port    => '587',
    #             :via     => :smtp,
    #             :via_options => {
    #               :address => 'smtp.gmail.com',
    #               :port    => '587', 
    #               :enable_starttls_auto => true, 
    #               :user_name            => 'praca@1000it.pl', 
    #               :password             => 'h76umfCaLLMEXK', 
    #               :authentication       => :plain, 
    #               :domain               => '1000it.pl'
    #             })
    # end

    # debug { puts "Hi!" }
    def debug
      yield if @debug
    end

    def deg2rad(deg)
      (deg * Math::PI / 180)
    end

    def rad2deg(deg)
      (deg * 180 / Math::PI)
    end

    def json(data = {})
      content_type 'application/json; charset=utf-8'
      Yajl::Encoder.encode(data)
    end

    def json_items(items = [])
      data = []
      h = {}

      items.all.each do |item|
        next if h.key?(item.token)
        h[item.token] = true
        data << { 
          'itemId'   => item.token,
          'imageUrl' => "http://sellastic.com/files/#{item.token}.png",
          'thumbnailUrl' => "http://sellastic.com/files/100_#{item.token}.png",
          'facebookId' => item.profile.facebook_id,
          'title' => item.title,
          'price' => item.price,
          'description' => item.description,
          'promoted' => (item.promoted ? 1 : 0),
          'sold' => (item.sold ? 1 : 0),
          'latitude' => item.latitude,
          'longitude' => item.longitude,
          'created_at' => item.created_at,
          'updated_at' => item.updated_at }
      end
      json({'items' => data})
    end

    def logged_in?
      !!@user
    end

    def user
      @user
    end
  end
end
