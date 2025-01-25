defmodule HelloWeb.UserController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.User
  import Ecto.Query

  def register(conn, _params) do
    render(conn, :register, layout: false)
  end

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

  def users(conn, _params) do
    users = Repo.all(User)
    json(conn, users)
  end

  # def get_user_by_user_key(conn, %{"user_key" => uuid}) do
  #   query = from(a in User, where: a.uuid == ^uuid, select: a)
  #   users = Repo.all(query)
  #   user = Enum.at(users, 0)
  #   if Enum.count(users) == 0 or Enum.count(users) > 1 do
  #     json(conn, %{success: false, message: "Invalid user key!"})
  #   else
  #     json(conn, %{success: true, user: user})
  #   end
  #   json(conn, %{success: false, message: "Something went wrong!"})
  # end

  def create_user(conn, %{"firstname" => firstname, "surname" => surname, "password" => password, "email" => email}) do
    try do
      changeset = User.changeset(%User{}, %{"firstname" => firstname, "surname" => surname, "password" => password, "email" => email, "plan" => "dev"})
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
    query = from(a in User, where: a.email == ^email and a.password == ^password, select: a)
    users = Repo.all(query)
    user = Enum.at(users, 0)
    if Enum.count(users) == 0 or Enum.count(users) > 1 do
      json(conn, %{success: false, message: "Invalid credentials!"})
    else
      json(conn, %{success: true, user: user})
    end
    json(conn, %{success: false, message: "Something went wrong!"})
  end
end
