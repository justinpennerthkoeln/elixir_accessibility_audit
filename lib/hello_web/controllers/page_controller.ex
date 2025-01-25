defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def test(conn, %{"id" => id}) do
    rulesA = File.read!("assets/rules/rules_a.json") |> Jason.decode!()
    rulesAA = File.read!("assets/rules/rules_aa.json") |> Jason.decode!()
    rules3 = File.read!("assets/rules/rules3.json") |> Jason.decode!()
    rulesMissing = File.read!("assets/rules/rules_missing.json") |> Jason.decode!()
    output = rulesA ++ rulesAA ++ rules3 ++ rulesMissing |> HelloWeb.Audit.doAudit("<input id=\"\"></input>")
    json(conn, output)
  end
end
