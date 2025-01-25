defmodule Hello.Repo.Migrations.UpdateUsersUuidDefaultGenUuid do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :uuid
    end
    alter table(:users) do
      add :uuid, :uuid, default: Ecto.UUID.generate(), null: false
    end
  end
end
