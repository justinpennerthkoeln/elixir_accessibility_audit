defmodule Hello.Repo.Migrations.CreateLoginsTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    create table(:logins) do
    add :uuid, :binary_id, null: false, default: fragment("uuid_generate_v4()")
    add :user_id, references(:users, on_delete: :delete_all), null: false
    timestamps()
    end

    create unique_index(:logins, [:uuid])
  end
end
