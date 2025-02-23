defmodule HelloWeb.UserController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.Users
  import Ecto.Query

  def register(conn, _params) do
    render(conn, :register, page_title: "Register", layout: false)
  end

  def login(conn, _params) do
    render(conn, :login, page_title: "Login", layout: false)
  end

  def users(conn, %{"filter" => filter}) do
    if(filter == "all") do
      users = Repo.all(Users)
      json(conn, users)
    else
      users = Repo.all(from(u in Users, where: ilike(u.username, ^"%#{filter}%")))
      json(conn, users)
    end
  end

  def auth(conn, _params) do
    json(conn, %{success: true, user_key: "aa12e220-48f3-482f-a362-dbe8bd2f1f4a"})
  end

  def create_user(conn, %{"username" => username, "email" => email, "password" => password}) do
    try do
      changeset = Users.changeset(%Users{}, %{"username" => username, "email" => email, "password" => password})
      case Repo.insert(changeset) do
        {:ok, _user} ->
          conn
          |> put_status(:created)
          |> json(%{success: true})
        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{success: false, message: "Something went wrong!"})
      end
    rescue
      _e ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{success: false, message: "Something went wrong!"})
    end
  end

  def check_credentials(conn, %{"email" => email, "password" => password}) do
    query = from(a in Users, where: a.email == ^email and a.password == ^password, select: a)
    users = Repo.all(query)
    user = Enum.at(users, 0)
    if Enum.count(users) == 0 or Enum.count(users) > 1 do
      json(conn, %{success: false, message: "Invalid credentials!"})
    else
      json(conn, %{success: true, user: user})
    end
  end
end
