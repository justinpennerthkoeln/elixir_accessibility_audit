defmodule HelloWeb.PDFKit do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  defstruct page_size: "A4"

  @style """
      <style>
        body {
          font-family: Arial, sans-serif;
        }

        .issue:not(:first-of-type) {
          margin-top: 3rem;
        }

        .issue-title:not(:first-of-type) {
          margin-top: 3rem;
        }

        .issue-title p {
          margin-top: -1rem;
        }

        .match {
          padding: 0 2rem;
          padding-bottom: 1rem;
          box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.30);
          page-break-inside: avoid;
        }

        .description {
          width: 70%;
        }

        .match-title {
          display: flex;
          justify-content: space-between;
        }

        .match > * {
          margin: 0;
          margin-top: 0.5rem;
        }

        .match a{
          color: #7177ed;
          text-decoration: none;
        }

        .match a:hover{
          color: #4d4f9e;
        }

        .match pre {
          background-color: #f4f4f4;
          padding: 1rem;
          border-radius: 5px;
          overflow-x: auto;
          margin-bottom: 1rem
        }

        .match .description {
          margin-top: -1rem;
          margin-bottom: 1rem;
          max-width: 70%;
        }

        .page-break {
          page-break-after: always;
        }
      </style>
    """

  # Issues from Project to PDF
  def to_project_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issues, project) do
    # Convert the issues list to HTML
    html_content = project_issues_to_html(issues, project)
    pdf_filename = UUID.uuid4()

    {:ok, file_path} = PdfGenerator.generate(html_content, filename: pdf_filename, encoding: "UTF-8")
    file_path
  end

  defp project_issues_to_html(issues, project) do
    """
    <html>
    <head>
      <meta charset="UTF-8">
      #{@style}
    </head>
    <body>
      <h1>Issue Report</h1>
      #{Enum.map(issues, fn issue ->
        """
        <div class="issue page-break">
          <div class="issue-title">
            <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
            <p>#{iso_date_to_readable_date(issue["inserted_at"])}</p>
          </div>
          <div class="matches">
            #{Enum.map(issue["matches"], fn {_key, match} ->
              """
              <div class="match">
                <div class="match-title">
                  <h3>#{match["heading"]} - WCAG: #{match["wcagClass"]}</h3>
                  <h3>Line: #{match["lineIndex"]}</h3>
                </div>
                <p class="description">#{match["description"]}</p>
                <pre><code>#{safe_to_string(html_escape(match["content"]))}</code></pre>
                <p>WCAG: #{match["wcag"]}</p>
                <a href="#{match["url"]}" target="_blank" rel="noopener noreferrer">more info</a>
              </div>
              """
            end) |> Enum.join("\n")}
          </div>
        </div>
        """
      end) |> Enum.join("\n")}
    </body>
    </html>
    """
  end

  # Issues from Audit to PDF #
  ############################
  def to_audit_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issues) do
    # Convert the audit list to HTML
    html_content = audit_issues_to_html(issues)
    pdf_filename = UUID.uuid4()

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename, encoding: "UTF-8")
    pdf_path
  end

  defp audit_issues_to_html(issues) do
    """
    <html>
    <head>
      <meta charset="UTF-8">
      #{@style}
    </head>
    <body>
      <h1>Audit Report</h1>
      #{
        Enum.map(issues, fn issue ->
          """
            <div class="issue page-break">
              <div class="issue-title">
                <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
                <p>#{iso_date_to_readable_date(issue["inserted_at"])} </p>
              </div>
              <div class="matches">
                #{Enum.map(issue["matches"], fn match ->
                  """
                    <div class="match">
                      <div class="match-title">
                        <h3>#{match["heading"]} - WCAG: #{match["wcagClass"]}</h3>
                        <h3>Line: #{match["lineIndex"]}</h3>
                      </div>
                      <p class="description">#{match["description"]}</p>
                      <pre><code>#{safe_to_string(html_escape(match["content"]))}</code></pre>
                      <p>WCAG: #{match["wcag"]}</p>
                      <a href="#{match["url"]}" target="_blank" rel="noopener noreferrer">more info</a>
                    </div>
                  """
                end) |> Enum.join("\n")}
              </div>
            </div>
          """
        end) |> Enum.join("\n")}
    </body>
    </html>
    """
  end

  # Single Issue to PDF #
  #######################
  def to_single_issue_pdf(%HelloWeb.PDFKit{} = _pdf_kit, issue) do
    html_content = single_issue_to_html(issue)
    pdf_filename = UUID.uuid4()

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename, encoding: "UTF-8")
    pdf_path
  end

  defp single_issue_to_html(issue) do
    """
    <html>
    <head>
      <meta charset="UTF-8">
      #{@style}
    </head>
    <body>
      <h1>Issue Report</h1>
      <div class="issue page-break">
        <div class="issue-title">
          <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
          <p>#{iso_date_to_readable_date(issue["inserted_at"])}</p>
        </div>
        <div class="matches">
          #{
            Enum.map(issue["matches"], fn {_key, match} ->
              """
              <div class="match">
                <div class="match-title">
                  <h3>#{match["heading"]} - WCAG: #{match["wcagClass"]}</h3>
                  <h3>Line: #{match["lineIndex"]}</h3>
                </div>
                <p class="description">#{match["description"]}</p>
                <pre><code>#{safe_to_string(html_escape(match["content"]))}</code></pre>
                <p>WCAG: #{match["wcag"]}</p>
                <a href="#{match["url"]}" target="_blank" rel="noopener noreferrer">more info</a>
              </div>
              """
            end) |> Enum.join("\n")
          }
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp iso_date_to_readable_date(string) do
    [date, time] = String.split(string, "T")
    [year, month, day] = String.split(date, "-")
    [hour, minute, _] = String.split(time, ":")
    "#{day}-#{month}-#{year} #{hour}:#{minute}"
  end

end
