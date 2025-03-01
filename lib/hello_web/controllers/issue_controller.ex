defmodule HelloWeb.IssueController do
  use HelloWeb, :controller
  alias Hello.Repo
  alias Hello.Issues
  import Ecto.Query

  def delete_issue(conn, %{"uuid" => uuid}) do
    issue = Repo.get_by(Issues, uuid: uuid)
    case issue do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, message: "Issue not found!"})
      _ ->
        Repo.delete(issue)
        conn
        |> put_status(:ok)
        |> json(%{success: true})
    end
  end

end
