defmodule Hello.Repo.Migrations.UpdateUsersAddingUuidIdentifier do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uuid, :string
    end
  end
end
