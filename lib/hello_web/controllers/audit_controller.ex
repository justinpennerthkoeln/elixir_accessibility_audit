defmodule HelloWeb.AuditController do
  use HelloWeb, :controller
  alias Hello.ApiKeys
  alias HelloWeb.PDFKit

  def doAudit(conn, params) do
    rulesA = File.read!("assets/rules/rules_a.json") |> Jason.decode!()
    rulesAA = File.read!("assets/rules/rules_aa.json") |> Jason.decode!()
    rules3 = File.read!("assets/rules/rules3.json") |> Jason.decode!()
    rulesMissing = File.read!("assets/rules/rules_missing.json") |> Jason.decode!()

    api_key = params["api_key"]
    filecontent = params["filecontent"]
    if api_key == nil or filecontent == nil do
      conn
      |> put_status(401)
      |> json(%{success: false, error: if api_key == nil do "No api_key Provided" else "No filecontent Found" end, message: if api_key == nil do "API key not found. Create a new API key at: http://localhost:4000/dashboard" else "Provide filecontent" end})
    else
      api_key = String.replace(api_key, " ", "+") |> ApiKeys.get_by_key()
      if api_key == nil do
        conn
        |> put_status(401)
        |> json(%{success: false, error: "Unauthorized", message: "API key not found. Create a new API key at: http://localhost:4000/dashboard"})
      else
        auditResult = rulesA ++ rulesAA ++ rules3 ++ rulesMissing |> HelloWeb.Audit.doAudit(filecontent)
        json(conn, auditResult)
      end
    end
  end

  def generate_pdf(conn, %{"issues" => issues, "project" => project}) do
    pdf_path =
      case project do
        false ->
          %HelloWeb.PDFKit{page_size: "A4"}
          |> PDFKit.to_audit_pdf(issues)
          |> String.replace("/tmp/", "")
        _ ->
          %HelloWeb.PDFKit{page_size: "A4"}
          |> PDFKit.to_project_pdf(issues, project)
          |> String.replace("/tmp/", "")
      end

    json(conn, %{pdf_path: pdf_path})
  end

  def pdf(conn, %{"name" => name}) do
    pdf_content = File.read!("/tmp/#{name}")

    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(200, pdf_content)
  end
end
