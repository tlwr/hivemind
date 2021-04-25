Sequel.migration do
  up do
    create_table(:e_pub_user_bookmarks) do
      primary_key :id

      foreign_key :e_pub_id
      foreign_key :user_id

      String :href

      unique [:e_pub_id, :user_id]
    end
  end

  down do
    drop_table(:e_pub_user_bookmarks)
  end
end
