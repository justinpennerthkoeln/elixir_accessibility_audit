defmodule HelloWeb.KeyController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.ApiKey
  import Ecto.Query

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def api_keys(conn, %{"id" => id}) do
    query = from(a in ApiKey, where: a.user_id == ^id, select: a)
    api_keys = Repo.all(query)
    if Enum.count(api_keys) == 0 do
      json(conn, %{success: false, info: "No api keys found for user"})
    else
      json(conn, %{success: true, keys: api_keys})
    end
  end

  def create_api_key(conn, %{"user_id" => user_id}) do
    try do
      changeset = ApiKey.changeset(%ApiKey{}, %{"user_id" => user_id, "api_key" => :crypto.strong_rand_bytes(32) |> Base.encode64()})
      case Repo.insert(changeset) do
        {:ok, api_key} ->
          conn
          |> put_status(:created)
          |> json(%{success: true, api_key: api_key.api_key, created_at: api_key.inserted_at})
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, errors: changeset.errors})
      end
    rescue
      _e ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, info: "An error occurred"})
    end
  end
end
