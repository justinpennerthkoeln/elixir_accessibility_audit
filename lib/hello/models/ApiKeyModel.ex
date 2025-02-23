defmodule Hello.ApiKeys do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:user_id, :api_key, :inserted_at, :updated_at]}
  schema "api_keys" do
    belongs_to :user, Hello.Users, foreign_key: :user_id, references: :id
    field :api_key, :binary_id
    timestamps()
  end

  def changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:user_id, :api_key])
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :api_key) do
      nil ->
        changeset = put_change(changeset, :api_key, Ecto.UUID.generate())
        changeset
      _ -> changeset
    end
  end

  def get_api_key_by_user_id(user_id) do
    query = from a in __MODULE__, where: a.user_id == ^user_id
    Repo.all(query)
  end

  def get_by_key(api_key) do
    query = from a in __MODULE__, where: a.api_key == ^api_key
    Repo.one(query)
  end

  def get_all_keys() do
    query = from a in __MODULE__
    Repo.all(query)
  end
end
