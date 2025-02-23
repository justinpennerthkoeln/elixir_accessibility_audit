defmodule Hello.Issues do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Ecto.Schema
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:uuid, :user_id, :project_id, :filename, :matches, :html, :matches_count, :status, :inserted_at, :updated_at]}
  schema "issues" do
    field :uuid, :binary_id
    belongs_to :user, Hello.Users, foreign_key: :user_id, references: :id
    belongs_to :project, Hello.Projects, foreign_key: :project_id, references: :id
    field :filename, :string
    field :matches, :map
    field :html, :string
    field :matches_count, :integer
    field :status, :string, default: "open"
    timestamps()
  end

  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:user_id, :project_id, :filename, :matches, :html, :matches_count])
    |> validate_required([:user_id, :project_id, :filename, :matches, :html, :matches_count])
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil -> put_change(changeset, :uuid, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
