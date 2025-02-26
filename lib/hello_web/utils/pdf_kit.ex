defmodule HelloWeb.PDFKit do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  defstruct page_size: "A4"

  # Issues from Project to PDF
  def to_project_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issues, project) do
    # Convert the issues list to HTML
    html_content = project_issues_to_html(issues, project)
    pdf_filename = UUID.uuid4()

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename)
    pdf_path
  end

  defp project_issues_to_html(issues, project) do
    """
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }

        .issue-title:not(:first-of-type) {
          margin-top: 3rem;
        }

        .issue-title p {
          margin-top: -1rem;
        }

        .match {
          margin-bottom: 10px;
          padding: 10px;
          box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.30);
          page-break-inside: avoid;
        }
      </style>
    </head>
    <body>
      <h1>Issue Report</h1>
      #{Enum.map(issues, &project_issue_to_html/1) |> Enum.join("\n")}
    </body>
    </html>
    """
  end

  defp project_issue_to_html(%{"filename" => filename, "matches_count" => matches_count, "inserted_at" => inserted_at, "matches" => matches}) do
    """
    <div class="issue page-break">
      <div class="issue-title">
        <h2>#{filename} - #{matches_count} Issues</h2>
        <p>#{inserted_at}</p>
      </div>
      <div class="matches">
        #{Enum.map(matches, fn {_key, match} -> project_match_to_html(match) end) |> Enum.join("\n")}
      </div>
    </div>
    """
  end

  defp project_match_to_html(%{"content" => content, "heading" => heading, "description" => description, "url" => url, "wcag" => wcag, "wcagClass" => wcagClass}) do
    """
    <div class="match">
      <h3>#{heading}</h3>
      <p>#{description}</p>
      <p>WCAG: #{wcag}</p>
      <p>WCAG Class: #{wcagClass}</p>
      <p>URL: #{url}</p>
      <pre><code>#{safe_to_string(html_escape(content))}</code></pre>
    </div>
    """
  end


  # Issues from Audit to PDF #
  ############################
  def to_audit_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issues) do
    # Convert the audit list to HTML
    html_content = audit_issues_to_html(issues)
    pdf_filename = UUID.uuid4()

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename)
    pdf_path
  end

  defp audit_issues_to_html(issues) do
    """
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }

        .issue-title:not(:first-of-type) {
          margin-top: 3rem;
        }

        .issue-title p {
          margin-top: -1rem;
        }

        .match {
          margin-bottom: 10px;
          padding: 10px;
          box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.30);
          page-break-inside: avoid;
        }
      </style>
    </head>
    <body>
      <h1>Audit Report</h1>
      #{Enum.map(issues, &audit_issue_to_html/1) |> Enum.join("\n")}
    </body>
    </html>
    """
  end

  defp audit_issue_to_html(issue) do
    """
    <div class="issue page-break">
      <div class="issue-title">
        <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
        <p>#{issue["inserted_at"]}</p>
      </div>
      <div class="matches">
        #{Enum.map(issue["matches"], &audit_match_to_html/1) |> Enum.join("\n")}
      </div>
    </div>
    """
  end

  defp audit_match_to_html(%{"content" => content, "heading" => heading, "description" => description, "url" => url, "wcag" => wcag, "wcagClass" => wcagClass}) do
    """
    <div class="match">
      <h3>#{heading}</h3>
      <p>#{description}</p>
      <p>WCAG: #{wcag}</p>
      <p>WCAG Class: #{wcagClass}</p>
      <p>URL: #{url}</p>
      <pre><code>#{safe_to_string(html_escape(content))}</code></pre>
    </div>
    """
  end

  # Single Issue to PDF #
  #######################
  def to_single_issue_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issue) do
    html_content = single_issue_to_html(issue)
    pdf_filename = UUID.uuid4()

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename)
    pdf_path
  end

  defp single_issue_to_html(issue) do
    """
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }

        .issue-title:not(:first-of-type) {
          margin-top: 3rem;
        }

        .issue-title p {
          margin-top: -1rem;
        }

        .match {
          margin-bottom: 10px;
          padding: 10px;
          box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.30);
          page-break-inside: avoid;
        }
      </style>
    </head>
    <body>
      <h1>Issue Report</h1>
      <div class="issue page-break">
        <div class="issue-title">
          <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
          <p>#{issue["inserted_at"]}</p>
        </div>
        <div class="matches">
          #{Enum.map(issue["matches"], fn {_key, match} -> single_match_to_html(match) end) |> Enum.join("\n")}
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp single_match_to_html(%{"content" => content, "heading" => heading, "description" => description, "url" => url, "wcag" => wcag, "wcagClass" => wcagClass}) do
    """
    <div class="match">
      <h3>#{heading}</h3>
      <p>#{description}</p>
      <p>WCAG: #{wcag}</p>
      <p>WCAG Class: #{wcagClass}</p>
      <p>URL: #{url}</p>
      <pre><code>#{safe_to_string(html_escape(content))}</code></pre>
    </div>
    """
  end

end
