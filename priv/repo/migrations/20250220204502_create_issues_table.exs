defmodule Hello.Repo.Migrations.CreateIssuesTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    execute("""
        DO $$
        BEGIN
          CREATE TYPE status AS ENUM ('open', 'fixed', 'closed');
        EXCEPTION
          WHEN duplicate_object THEN
            -- do nothing, type already exists
            NULL;
        END
        $$;
        """)

    create table(:issues) do
    add :uuid, :binary_id, null: false, default: fragment("uuid_generate_v4()")
    add :filename, :string, null: false
    add :user_id, references(:users, on_delete: :delete_all), null: false
    add :project_id, references(:projects, on_delete: :delete_all), null: false
    add :matches, :json, null: false
    add :html, :string, null: false
    add :matches_count, :integer, null: false
    add :status, :status, null: false, default: "open"
    timestamps()
    end

    create unique_index(:issues, [:uuid])
  end
end
