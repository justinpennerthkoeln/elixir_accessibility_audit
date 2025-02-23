defmodule Hello.Logins do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Schema
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:uuid, :user_id, :inserted_at, :updated_at]}
  schema "logins" do
    field :uuid, :binary_id
    belongs_to :user, Hello.Users, foreign_key: :user_id, references: :id
    timestamps()
  end

  def changeset(login, attrs) do
    login
    |> cast(attrs, [:uuid, :user_id])
    |> validate_required([:uuid, :user_id])
    |> unique_constraint(:uuid)
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
