require 'app/libraries'
require 'fileutils'

module Sellastic
  class App < Sinatra::Base
    helpers Sellastic::Helpers
    helpers Sinatra::ContentFor2

    dir = File.expand_path(File.dirname(__FILE__))
    set :public,  "#{dir}/public"
    set :views,   "#{dir}/views"
    set :root,    RACK_ROOT
    set :app_file, __FILE__
    set :static,   true

    enable :sessions

    def initialize(*args)
      super
      @debug = ENV['DEBUG']
    end

    #
    # routes
    #

    before do
      headers "Content-Type" => "text/html; charset=utf-8"
    end

    # Redirect trailing slashes
    get %r{(.+)/$} do |r| redirect r; end;

    get '/?' do
      '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Sellastic</title>
</head>
<body>
<img src="/logo.png" style="display:block;margin-left:auto;margin-right:auto;">
</body>
</html>'
    end

    get '/test' do
      '
<html>
<body>
<form action="/item" enctype="multiform/form-data" method="post">
<fieldset>
fbid: <input type="text" name="facebookId"><br>
title: <input type="text" name="title"><br>
description: <input type="text" name="description"><br>
price: <input type="text" name="price"><br>
lat: <input type="text" name="lat"><br>
long: <input type="text" name="long"><br>
tags: <input type="text" name="tags"><br>
Image:<input name="image" type="file">
<input type="submit" value="Upload">
</fieldset>
</form>
</body>
</html>
'
    end

    post '/item' do
      tempfile = params['image'][:tempfile]

      token = ''
      while token.blank? or (not Item.filter(:token => token).empty?)
        token = rand(36**12).to_s(36) while token.length < 8
        token = token[0..7]
      end
      image_path = "./public/files/#{token}.png"
      FileUtils.cp(tempfile.path, image_path)

      profile = Profile.find_or_create(params['facebookId'])
      item = Item.new(:token => token,
                      :title => params['title'],
                      :description => params['description'],
                      :price => params['price'],
                      :latitude => params['lat'],
                      :longitude => params['long'],
                      :image_path => image_path,
                      :promoted => false)
      item.latitude  = deg2rad(item.latitude)
      item.longitude = deg2rad(item.longitude)
      item.save
      params['tags'].split(/\s+/).each do |t|
        t = Tag.find_or_create(t)
        item.add_tag(t)
      end
      profile.add_item(item)

      json({'itemId' => item.token})
    end

    post '/item/edit/:itemid' do
      item = Item.filter(:id => params[:itemid]).first

      item.title = params['title']
      item.description = params['description']
      item.price = params['price']
      item.save

      item.remove_all_tags
      params['tags'].split(/\s+/).each do |t|
        t = Tag.find_or_create(t)
        item.add_tag(t)
      end
      json({'itemId' => item.token})
    end


    get '/item/:id' do
      item = Item.find_by_token(params[:id])
      tags = item.tags_dataset.all.map {|t| t.name}
      json({ 'facebookId' => item.profile.facebook_id,
             'title' => item.title,
             'description' => item.description,
             'price' => item.price,
             'tags' => tags,
             'lat' => item.latitude,
             'long' => item.longitude,
             'imageUrl' => "http://sellastic.com/files/#{item.token}.png" })
    end

    get '/item/:id/promote' do
      item = Item.find_by_token(params[:id])
      item.promoted = true
      item.save
      json({'promoted' => item.promoted})      
    end
    
    post '/items/promoted' do
      items = Item.filter(:promoted => true).all
      items = items.to_a.sort_by { rand }
      json_items(items)
    end

    post '/items/friends' do
      fbid = params['facebookId']
      profile = Profile.find_or_create(fbid)
      ids = profile.friends_dataset.all.map {|x| x.id}

      items = []
      ids.each do |id|
        items += Item.filter(:profile_id  => id).all
      end
      json_items(items)
    end

    post '/items/location' do
      lat = params['lat'].to_f
      lon = params['long'].to_f
      rad = params['radius'].to_f # in kilometers
      items = Item.find_nearby(deg2rad(lat), deg2rad(lon), rad * 1000).all
      json_items(items)
    end

    post '/items/tag' do
      tag = params['tag']
      # todo: temporary hack :)
      items = Item.eager(:tags).all.find_all {|x| (x.tags.map {|y| y.name}).include?(tag)}
      json_items(items)
    end

    post '/friends/:fbid' do
      profile = Profile.find_or_create(params[:fbid])
      friends = params[:friends].split(/\s+/)
      friends.each do |fid|
        profile.add_friend(Profile.find_or_create(fid))
      end
      friends.size.to_s
    end

    get '/tags/alpha' do
      ts = Tag.order(:name.asc).all.map {|x| x.name }
      json({'tags' => ts})
    end

    get '/tags/top' do
      ts = DB[:items_tags].group_and_count(:tag_id___name).order(:count.desc)
      ts = ts.limit(10).all
      tags = ts.map { |x| Tag.filter(:id => x[:name]).first.name }
      json({'tags' => tags})
    end


      # p = params['talent']
      # t = Talent.new(p.slice('email', 'skills', 'experience_bio', 'gold_star_bio',
      #                        'experience_level', 'willing_to_travel'))
      # t.location = Location.filter(:city => p['city_name']).first
      # if t.valid?
      #   t.published = true
      #   t.moderate  = true
      #   # TODO: temporarily setting created_at and updated_at
      #   t.created_at = Time.now
      #   t.updated_at = t.created_at

      #   @talent = t.save
      #   # TODO: send_email asynchronously
      #   send_email_praca(t.email, 
      #                    'Witamy w 1000it.pl!',
      #                    erb(:email_talent_welcome, :layout => false))
      #   # TODO: make a better email_talent_welcome template :)
      #   redirect to(url_for('new_talent_thanks'))
      # else
      #   @talent = t
      #   @talent_city_name = t.location ? t.location.city : ''
      #   erb :new_talent
      # end


    # get '/cities/autocomplete' do
    #   limit = 10
    #   q = params['q']
    #   return json('') if q.nil?
    #   cities = Location.order(:city).select(:city)
    #   if q.blank?
    #     res = cities.limit(limit)
    #   else
    #     res =  cities.filter(:city.ilike("#{q}%")).limit(limit).all
    #     res += cities.filter(:city.ilike("_%#{q}%")).limit(limit - res.size).all if res.size < limit
    #   end
    #   res = res.map { |c| c.city }.join("\n")
    #   return json(res)
    # end

    # get '/informatyk/rejestracja' do
    #   @title = "Zdolny Informatyk"
    #   @talent = Talent.new
    #   @talent_city_name = ''
    #   erb :new_talent
    # end

    # # TODO: needs integration test for submitting form and saving to database
    # # TODO: needs integration test of sending email
    # post '/informatyk/rejestracja' do
    #   p = params['talent']
    #   t = Talent.new(p.slice('email', 'skills', 'experience_bio', 'gold_star_bio',
    #                          'experience_level', 'willing_to_travel'))
    #   t.location = Location.filter(:city => p['city_name']).first
    #   if t.valid?
    #     t.published = true
    #     t.moderate  = true
    #     # TODO: temporarily setting created_at and updated_at
    #     t.created_at = Time.now
    #     t.updated_at = t.created_at

    #     @talent = t.save
    #     # TODO: send_email asynchronously
    #     send_email_praca(t.email, 
    #                      'Witamy w 1000it.pl!',
    #                      erb(:email_talent_welcome, :layout => false))
    #     # TODO: make a better email_talent_welcome template :)
    #     redirect to(url_for('new_talent_thanks'))
    #   else
    #     @talent = t
    #     @talent_city_name = t.location ? t.location.city : ''
    #     erb :new_talent
    #   end
    # end

    # get '/witamy' do
    #   'TODO: Thanks!'
    # end

    # get '/praca/oferty' do
    #   @title  = 'Oferty pracy'
    #   @offers = JobOffer.order(:date_created.desc).all
    #   erb :job_offers
    # end

    # get '/praca/oferty/django/json' do
    #   offers = []
    #   JobOffer.order(:date_created.desc).all do |j|
    #     o = { 'company_name'     => j.company_name,
    #           'company_location' => j.company_location,
    #           'cv_email'         => j.email_cv,
    #           'date_added'       => j.date_created,
    #           'job_description'  => j.description,
    #           'job_rewards'      => j.rewards,
    #           'job_title'        => j.title,
    #           'url'              => "http://www.1000it.pl/praca/oferta/#{j.token}"
    #     }
    #     offers << o
    #   end
    #   return json(offers)
    # end

    #
    # error handlers
    #

    not_found do
      erb :'404'
    end

    # TODO: set show exceptions ?
    #
    # error do
    #   erb :'500'
    # end

    #
    # route helpers
    #
    
  end
end
