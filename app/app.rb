require 'app/libraries'

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

    get '/foo/?' do
      'test'
    end

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
