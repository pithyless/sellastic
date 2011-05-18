require 'testbelt'

DB[:items_tags].delete
Tag.delete
Item.delete
Profile.delete

context 'POST /item' do
  asserts('Empty DB') { Item.count }.equals(0)

  helper(:params) do
    { 'facebookId' => 'test42',
      'title' => 'title',
      'description' => 'description',
      'price' => '$234.23',
      'lat' => '23.42334',
      'long' => '21.4453',
      'tags' => 'one two three',
      'image' => Rack::Test::UploadedFile.new('test/factory.png', 'image/png')
    }
  end
  
  context 'Upload' do
    setup do
      post '/item', params
      last_response
    end

    asserts('Status') {topic.status}.equals(200)
    asserts('added item'){ Item.count }.equals(1)
    asserts('response') {topic.body =~ /{"itemId":"\w+"}/}

    context 'GET /item/:id' do
      helper(:itemid) { /{"itemId":"(\w+)"}/.match(topic.body)[1] }
      setup do
        @itemid = itemid
        get "/item/#{itemid}"
        last_response
      end

      asserts('Status') {topic.status}.equals(200)
      asserts('response') {topic.body ==
        "{\"facebookId\":\"test42\",\"title\":\"title\",\"description\":\"description\",\"price\":\"$234.23\",\"tags\":[\"one\",\"two\",\"three\"],\"lat\":0.408814404814089,\"long\":0.37429109407794,\"thumbnailUrl\":\"http://sellastic.com/files/100_#{@itemid}.png\",\"imageUrl\":\"http://sellastic.com/files/#{@itemid}.png\"}" }
    end
  end
end




# context 'POST /authenticate' do
#   context 'good' do
#     setup do
#       clear_cookies
#       post '/authenticate', :facebookId => 'test123'
#       last_response
#     end

#     asserts('Status') { topic.status }.equals(200)
#     asserts('Sets session cookie') do
#       last_response.headers['Set-Cookie'] =~ /rack.session=/
#     end

#     context 'cookie is usable' do
#       setup { post '/logintest' }
#       asserts('Status') { topic.status }.equals(200)
#       asserts('User login') { topic.body }.equals('OK: test123')

#       context 'other login' do
#         setup { post '/authenticate', :facebookId => 'test321'; post '/logintest' }
#         asserts('Status') { topic.status }.equals(200)
#         asserts('User login') { topic.body }.equals('OK: test321')
#       end
#     end
#   end

#   context 'bad' do
#     setup do
#       clear_cookies
#       post '/authenticate', :facebookId => ''
#       last_response
#     end

#     denies('Status') { topic.status }.equals(403)
#   end

#   context 'bad secret' do
#     # TODO: denies if secret hash is miscalculated
#   end
# end


#   # asserts('one item'){ Item.count }.equals(1)

#   # context 'Detailed view' do
#   #   setup do
#   #     profile = user.profile
#   #     item = Item.save_new(profile,
#   #                   :facebook_id => 'test123',
#   #                   :title       => 'title',
#   #                   :description => 'description',
#   #                   :price       => '$123.23',
#   #                   :lat         => '24.1234',
#   #                   :lon         => '12.2345',
#   #                   :tags        => 'cat dogs book')
#   #   end
#   # end

#   # TODO: /item/:id

#   # TODO: /edit



# #     # TODO
# #     # asserts('Should save'){ false}
# #     # asserts('Set token'){ false }
# #     # asserts('Unique token'){ false }
# #     # asserts('Set date_created'){ false }

# #   end
# # end
