defmodule Hello.Repo.Migrations.CreateMemberTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    execute("""
        DO $$
        BEGIN
          CREATE TYPE role AS ENUM ('owner', 'member', 'viewer');
        EXCEPTION
          WHEN duplicate_object THEN
            -- do nothing, type already exists
            NULL;
        END
        $$;
        """)

    create table(:members) do
    add :uuid, :binary_id, null: false, default: fragment("uuid_generate_v4()")
    add :user_id, references(:users, on_delete: :delete_all), null: false
    add :project_id, references(:projects, on_delete: :delete_all), null: false
    add :role, :role, default: "member"
    timestamps()
    end

    create unique_index(:members, [:uuid])
  end
end
