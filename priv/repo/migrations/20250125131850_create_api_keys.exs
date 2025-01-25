defmodule Hello.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :api_key, :string

      timestamps()
    end
  end
end
