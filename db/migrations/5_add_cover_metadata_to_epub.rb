Sequel.migration do
  up do
    alter_table :e_pubs do
      add_column :cover_blob, File
      add_column :cover_media_type, String
    end
  end

  down do
    alter_table :e_pubs do
      drop_column :cover_blob
      drop_column :cover_media_type
    end
  end
end
