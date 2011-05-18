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

      # make thumbnail - quick #swwaw hack :)
      `convert #{image_path} -resize 100x100 ./public/files/100_#{token}.png`

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
      item = Item.filter(:token => params[:itemid]).first

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
             'thumbnailUrl' => "http://sellastic.com/files/100_#{item.token}.png",
             'imageUrl' => "http://sellastic.com/files/#{item.token}.png" })
    end

    get '/item/:id/promote' do
      item = Item.find_by_token(params[:id])
      item.promoted = true
      item.save
      json({'promoted' => item.promoted})      
    end

    post '/item/:id/delete' do
      item = Item.find_by_token(params[:id])
      item.deleted = true
      item.save
      json({'deleted' => item.deleted})      
    end

    post '/item/:id/sell' do
      item = Item.find_by_token(params[:id])
      item.sold = true
      item.save
      json({'sold' => item.sold})      
    end
    
    post '/items/promoted' do
      items = Item.to_buy.filter(:promoted => true).all
      items = items.to_a.sort_by { rand }
      json_items(items)
    end

    post '/items/friends' do
      fbid = params['facebookId']
      profile = Profile.find_or_create(fbid)
      ids = profile.friends_dataset.all.map {|x| x.id}

      items = []
      ids.each do |id|
        items += Item.to_buy.filter(:profile_id  => id).all
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
      items = Item.to_buy.eager(:tags).all.find_all {|x| (x.tags.map {|y| y.name}).include?(tag)}
      json_items(items)
    end

    post '/items/profile' do
      profile = Profile.find_or_create(params['facebookId'])
      items = Item.to_buy.filter(:profile_id => profile.id).all
      json_items(items)
    end

    post '/items/search' do
      q = params['query']
      items = Item.to_buy
      items = items.filter(:title.ilike("%#{q}%") | :description.ilike("%#{q}%")).all
      # todo: search by tags
      json_items(items)
    end

    post '/items/friendsnearby' do
      lat = params['lat'].to_f
      lon = params['long'].to_f
      rad = params['radius'].to_f # in kilometers
      items_ds = Item.find_nearby(deg2rad(lat), deg2rad(lon), rad * 1000)

      fbid = params['facebookId']
      profile = Profile.find_or_create(fbid)
      ids = profile.friends_dataset.all.map {|x| x.id}

      items = []
      ids.each do |id|
        items += items_ds.filter(:profile_id  => id).all
      end
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

    get '/mapdata.json' do
      lat = 52.2296756
      lon = 21.0122287
      rad = 10
      items = Item.find_nearby(deg2rad(lat), deg2rad(lon), rad * 1000).all

      markers = items.map do |item|
        { 'lat' => rad2deg(item.latitude),
          'lng' => rad2deg(item.longitude),
          'html' => "<div id='scale-up' style='height: 230px'><img src='/files/#{item.token}.png' style='vertical-align:middle;height:100%;'/></div><br> #{item.description}",
          'label' => item.title,
          'icon_url' =>  "/files/#{item.token}.png"
        }
      end

      json({ "markers" => markers,
             "lines" => []})
    end

    get '/map' do
      erubis :map, :layout => false
    end

    #
    # error handlers
    #

    not_found do
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
