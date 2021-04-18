Sequel.migration do
  up do
    create_table(:events) do
      primary_key :id

      String :kind, null: false
      String :raw_metadata, null: false
    end
  end

  down do
    drop_table(:events)
  end
end
