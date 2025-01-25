defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:id, :uuid, :firstname, :surname, :email, :plan, :inserted_at, :updated_at]}
  schema "users" do
    field :uuid, Ecto.UUID, default: Ecto.UUID.generate()
    field :firstname, :string
    field :surname, :string
    field :password, :string
    field :email, :string
    field :plan, :string, default: "free"

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:firstname, :surname, :password, :email, :plan])
    |> validate_required([:firstname, :surname, :password, :email, :plan])
  end

  def get_user_by_uuid(uuid) do
    Repo.get_by(__MODULE__, uuid: uuid)
  end

end
