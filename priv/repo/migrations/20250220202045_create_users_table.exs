defmodule Hello.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    execute("""
          DO $$
          BEGIN
            CREATE TYPE plan AS ENUM ('free', 'dev', 'pro');
          EXCEPTION
            WHEN duplicate_object THEN
              -- do nothing, type already exists
              NULL;
          END
          $$;
          """)

    create table(:users) do
      add :uuid, :binary_id, null: false, default: fragment("uuid_generate_v4()")
      add :username, :string, null: false
      add :email, :string, null: false
      add :password, :string, null: false
      add :plan, :plan, null: false, default: "free"
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
