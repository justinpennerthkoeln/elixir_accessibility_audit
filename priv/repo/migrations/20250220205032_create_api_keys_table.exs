defmodule Hello.Repo.Migrations.CreateApiKeysTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    create table(:api_keys) do
      add :api_key, :binary_id, null: false, default: fragment("uuid_generate_v4()")
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:api_keys, [:api_key])
  end
end
