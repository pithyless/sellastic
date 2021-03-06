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

    context 'POST /item/edit/:id' do
      helper(:itemid) { /{"itemId":"(\w+)"}/.match(topic.body)[1] }
      setup do
        @itemid = itemid
        post "/item/edit/#{itemid}", params.merge({'title' => 'title2',
                                                    'description' => 'description2',
                                                    'price' => '$934.23',
                                                    'tags' => 'one three five seven'})
        last_response
      end

      asserts('Status') {topic.status}.equals(200)
      asserts('response') { topic.body == "{\"itemId\":\"#{@itemid}\"}" }

    context 'Edited GET /item/:id' do
        setup { get "/item/#{@itemid}" }

        asserts('Status') {topic.status}.equals(200)
        asserts('response') {topic.body ==
          "{\"facebookId\":\"test42\",\"title\":\"title2\",\"description\":\"description2\",\"price\":\"$934.23\",\"tags\":[\"one\",\"three\",\"five\",\"seven\"],\"lat\":0.408814404814089,\"long\":0.37429109407794,\"thumbnailUrl\":\"http://sellastic.com/files/100_#{@itemid}.png\",\"imageUrl\":\"http://sellastic.com/files/#{@itemid}.png\"}" }
      end
    end
  end
end

context 'Item' do
  setup { @item = Item.all[0] }
  asserts { topic.promoted == false }

  context 'Promote' do
    setup { get "/item/#{topic.token}/promote" }
    asserts('Status') {topic.status}.equals(200)
    asserts('response') {topic.body}.equals('{"promoted":true}')
    asserts('item promoted'){ @item.reload.promoted == true }
  end
end


