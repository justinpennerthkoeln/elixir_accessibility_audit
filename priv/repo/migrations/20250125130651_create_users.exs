defmodule Hello.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :firstname, :string
      add :surname, :string
      add :password, :string
      add :email, :string
      add :plan, :string, default: "free"

      timestamps()
    end
  end
end
