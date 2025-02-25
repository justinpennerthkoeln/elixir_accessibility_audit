defmodule HelloWeb.PDFKit do
  import Phoenix.HTML
  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  defstruct page_size: "A4"

  def to_pdf(%HelloWeb.PDFKit{} = pdf_kit, issues) do
    # Convert the issues list to HTML
    html_content = issues_to_html(issues)
    pdf_filename = UUID.uuid4() <> ".pdf"

    IO.inspect(issues)

    {:ok, pdf_path} = PdfGenerator.generate(html_content, filename: pdf_filename)
    pdf_path
  end

  defp issues_to_html(issues) do
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
      #{Enum.map(issues, &issue_to_html/1) |> Enum.join("\n")}
    </body>
    </html>
    """
  end

  defp issue_to_html(issue) do
    """
    <div class="issue page-break">
      <div class="issue-title">
        <h2>#{issue["filename"]} - #{issue["matches_count"]} Issues</h2>
        <p>#{issue["inserted_at"]}</p>
      </div>
      <div class="matches">
        #{Enum.map(issue["matches"], fn {_key, match} -> match_to_html(match) end) |> Enum.join("\n")}
      </div>
    </div>
    """
  end

  defp match_to_html(%{"content" => content, "heading" => heading, "description" => description, "url" => url, "wcag" => wcag, "wcagClass" => wcagClass}) do
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
