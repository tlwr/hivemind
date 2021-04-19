Sequel.migration do
  up do
    alter_table :e_pubs do
      add_index :uploader_id
    end
  end

  down do
    alter_table :e_pubs do
      drop_index :uploader_id
    end
  end
end
