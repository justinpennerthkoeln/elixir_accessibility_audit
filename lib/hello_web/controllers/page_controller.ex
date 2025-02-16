defmodule HelloWeb.PageController do
  use HelloWeb, :controller
  alias Hello.User
  alias Hello.ApiKey

  def dashboard(conn, params) do
    user_key = params["user_key"]
    if user_key != nil do
      user = User.get_user_by_uuid(user_key)
      api_keys = ApiKey.get_api_key_by_user_id(user.id)
      render(conn, :dashboard, layout: false, api_keys: api_keys, user_id: user.id)
    else
      render(conn, :dashboard, layout: false, api_keys: [], user_id: nil)
    end

  end
end
