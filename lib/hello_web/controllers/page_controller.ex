defmodule HelloWeb.PageController do
  use HelloWeb, :controller
  alias Hello.Users
  alias Hello.ApiKeys

  def dashboard(conn, params) do
    user_key = params["user_key"]
    auth = params["auth"]

    if user_key != nil do
      user = Users.get_user_by_uuid(user_key)
      api_keys = ApiKeys.get_api_key_by_user_id(user.id)
      render(conn, :dashboard, page_title: "Dashboard", layout: false, api_keys: api_keys, user_id: user.id)
    else
      render(conn, :dashboard, page_title: "Dashboard", layout: false, api_keys: [], user_id: nil)
    end

  end
end
