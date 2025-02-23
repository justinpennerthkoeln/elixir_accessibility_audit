defmodule Hello.Projects do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.Repo

  @derive {Jason.Encoder, only: [:uuid, :name, :inserted_at, :updated_at]}
  schema "projects" do
    field :uuid, :binary_id
    field :name, :string
    timestamps()
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :uuid])
    |> put_uuid()
  end

  defp put_uuid(changeset) do
    case get_field(changeset, :uuid) do
      nil ->
        changeset = put_change(changeset, :uuid, Ecto.UUID.generate())
        changeset
      _ -> changeset
    end
  end

  def get_project_by_id(id) do
    Repo.get_by(__MODULE__, id: id)
  end
end
