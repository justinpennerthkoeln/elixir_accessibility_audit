defmodule HelloWeb.PageController do
  use HelloWeb, :controller
  alias Hello.User
  alias Hello.ApiKey

  def dashboard(conn, params) do
    # The home page is often custom made,
    # so skip the default app layout.
    user_key = params["user_key"]
    user = User.get_user_by_uuid(user_key)
    api_keys = ApiKey.get_api_key_by_user_id(user.id)
    render(conn, :dashboard, layout: false, api_keys: api_keys, user_id: user.id)
  end

  def test(conn, %{"id" => _id}) do
    rulesA = File.read!("assets/rules/rules_a.json") |> Jason.decode!()
    rulesAA = File.read!("assets/rules/rules_aa.json") |> Jason.decode!()
    rules3 = File.read!("assets/rules/rules3.json") |> Jason.decode!()
    rulesMissing = File.read!("assets/rules/rules_missing.json") |> Jason.decode!()
    output = rulesA ++ rulesAA ++ rules3 ++ rulesMissing |> HelloWeb.Audit.doAudit("<input id=\"\"></input>")
    json(conn, output)
  end
end
