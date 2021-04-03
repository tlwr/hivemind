Sequel.migration do
  up do
    create_table(:e_pubs) do
      primary_key :id

      String :title, null: false
      String :creator, null: false
      String :publisher, null: false

      File :epub, null: false
    end
  end

  down do
    drop_table(:e_pubs)
  end
end
