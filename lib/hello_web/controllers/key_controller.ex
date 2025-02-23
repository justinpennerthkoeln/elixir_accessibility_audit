defmodule HelloWeb.KeyController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.ApiKeys
  alias Hello.Users
  import Ecto.Query

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def api_keys(conn, %{"id" => id}) do
    query = from(a in ApiKeys, where: a.user_id == ^id, select: a)
    api_keys = Repo.all(query)
    if Enum.count(api_keys) == 0 do
      json(conn, %{success: false, info: "No api keys found for user"})
    else
      json(conn, %{success: true, keys: api_keys})
    end
  end

  def api_keys_by_uuid(conn, %{"uuid" => uuid}) do
    query = from(a in Users, where: a.uuid == ^uuid, select: a)
    users = Repo.all(query)
    user = Enum.at(users, 0)
    if Enum.count(users) == 0 or Enum.count(users) > 1 do
      json(conn, %{success: false, message: "Invalid user key!"})
    else
      query = from(a in ApiKeys, where: a.user_id == ^user.id, select: a)
      api_keys = Repo.all(query)
      json(conn, %{success: true, keys: api_keys})
    end
  end

  def create_api_key(conn, %{"user_id" => user_id}) do
    try do
      changeset = ApiKeys.changeset(%ApiKeys{}, %{"user_id" => user_id})
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

  def delete_api_key(conn, %{"id" => id}) do
    try do
      case Repo.get(ApiKeys, id) do
        nil ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, info: "Api key not found"})

        api_key ->
          case Repo.delete(api_key) do
            {:ok, _} ->
              conn
              |> put_status(:ok)
              |> json(%{success: true, info: "Api key deleted"})

            {:error, _} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{success: false, info: "Failed to delete api key"})
          end
      end
    rescue
      _e ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, info: "An error occurred"})
    end
  end
end
