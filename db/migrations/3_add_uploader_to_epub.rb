Sequel.migration do
  up do
    alter_table(:e_pubs) do
      add_foreign_key :uploader_id, :users
    end
  end

  down do
    alter_table(:e_pubs) do
      drop_foreign_key :uploader_id
    end
  end
end
