defmodule Hello.ApiKey do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:id, :user_id, :api_key, :inserted_at, :updated_at]}
  schema "api_keys" do
    field :user_id, :integer
    field :api_key, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id, :api_key])
    |> validate_required([:user_id, :api_key])
  end

  def get_api_key_by_user_id(user_id) do
    query = from a in __MODULE__, where: a.user_id == ^user_id
    Repo.all(query)
  end
end
