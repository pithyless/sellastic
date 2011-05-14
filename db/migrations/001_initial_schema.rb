Sequel.migration do
  up do
    create_table(:profiles) do
      primary_key :id

      String :facebook_id, :null => false, :unique => true

      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table(:friends) do
      foreign_key :jack_id, :profiles, :null => false
      foreign_key :jill_id, :profiles, :null => false
    end
  
    create_table(:items) do
      primary_key :id

      String :image_path,  :null => false
      String :title,       :null => false
      String :description, :null => false
      BigDecimal :price,   :null => false, :size => [10, 2]
      Float  :latitude,    :null => false
      Float  :longitude,   :null => false

      Time :created_at, :null => false
      Time :updated_at, :null => false
    end

    create_table(:tags) do
      primary_key :id

      String name, :null => false, :unique => true
    end

    create_table(:items_tags) do
      foreign_key :item_id, :items, :null => false
      foreign_key :tag_id,  :tags, :null => false
    end
  end

  down do
    drop_table :friends
    drop_table :items_tags
    drop_table :tags
    drop_table :items
    drop_table :profiles
  end
end
