defmodule Hello.Members do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:uuid, :user_id, :project_id, :role, :inserted_at, :updated_at]}
  schema "members" do
    field :uuid, :binary_id
    belongs_to :user, Hello.Users, foreign_key: :user_id, references: :id
    belongs_to :project, Hello.Projects, foreign_key: :project_id, references: :id
    field :role, :string, default: "member"
    timestamps()
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :project_id, :role])
    |> validate_required([:user_id, :project_id, :role])
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
