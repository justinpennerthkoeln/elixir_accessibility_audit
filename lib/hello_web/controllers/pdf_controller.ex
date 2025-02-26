defmodule HelloWeb.PdfController do
  use HelloWeb, :controller
  alias HelloWeb.PDFKit

  def generate_audit_pdf(conn, %{"issues" => issues}) do
    pdf_path =
      %HelloWeb.PDFKit{page_size: "A4"}
      |> PDFKit.to_audit_pdf(issues)
      |> String.replace("/tmp/", "")

    json(conn, %{pdf_path: pdf_path})
  end

  def generate_project_pdf(conn, %{"issues" => issues, "project" => project}) do
    pdf_path =
      %HelloWeb.PDFKit{page_size: "A4"}
      |> PDFKit.to_project_pdf(issues, project)
      |> String.replace("/tmp/", "")

    json(conn, %{pdf_path: pdf_path})
  end

  def generate_single_issue_pdf(conn, %{"issue" => issue}) do
    pdf_path =
      %HelloWeb.PDFKit{page_size: "A4"}
      |> PDFKit.to_single_issue_pdf(issue)
      |> String.replace("/tmp/", "")

    json(conn, %{pdf_path: pdf_path})
  end

  def pdf(conn, %{"name" => name}) do
    pdf_content = File.read!("/tmp/#{name}")

    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(200, pdf_content)
  end
end
