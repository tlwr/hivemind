Sequel.migration do
  up do
    create_table(:e_pub_collections) do
      foreign_key :e_pub_id
      foreign_key :collection_id
    end

    create_table(:collections) do
      primary_key :id
      String :title, null: false

      foreign_key :creator_id
    end
  end

  down do
    drop_table(:e_pub_collections)
    drop_table(:collections)
  end
end
