defmodule Hello.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")

    create table(:projects) do
    add :uuid, :binary_id, null: false, default: fragment("uuid_generate_v4()")
    add :name, :string, null: false
    timestamps()
    end

    create unique_index(:projects, [:uuid])
  end
end
