defmodule Hello.Users do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:uuid, :username, :email, :plan, :inserted_at, :updated_at]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string
    field :plan, :string, default: "free"
    field :uuid, :binary_id
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_required([:username, :password, :email])
    |> unique_constraint(:email)
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end

  def get_user_by_uuid(uuid) do
    Repo.get_by(__MODULE__, uuid: uuid)
  end

end
