defmodule HelloWeb.Audit do

  def doAudit(rules, content) do
    initial_state = %{counter: 0, matches: [], content: content}

    Enum.reduce(rules, initial_state, fn rule, acc ->
      # internalHierarchy
      acc = if rule["rule_type"] == "internal hierarchy" do
        Enum.reduce(rule["tags"], acc, fn tag, acc_inner ->
          auditInternalHierarchy(rule, tag, acc_inner)
        end)
      else
        acc
      end

      # Linking processing
      acc = if rule["rule_type"] == "linking" do
        Enum.reduce(rule["tags"], acc, fn tag, acc_inner ->
          auditLinking(rule, tag, acc_inner)
        end)
      else
        acc
      end

      # Rules without specific type
      acc = if rule["rule_type"] == nil do
        Enum.reduce(rule["tags"], acc, fn tag, acc_inner ->
          audit(rule, tag, acc_inner)
        end)
      else
        acc
      end

      acc
    end)
    |> addLineNumber()
  end

  defp auditInternalHierarchy(rule, tag, acc) do
    regex = rule["regex"] |> String.replace(~r{tag}, tag)
    regex_replace = rule["regex_replace"]
    regex_check_content = rule["regex_check_content"]
    identifier = "data-audit-error" # rule["identifier"]

    Regex.scan(~r{#{regex}}, acc.content)
    |> Enum.reduce(acc, fn match, acc_inner ->
      content = Enum.at(match, 0) |> String.replace(~r{#{regex_replace}}, "")
      if !String.match?(content, ~r{#{regex_check_content}}) do
        appendError(identifier, match, rule, acc_inner)
      else
        acc_inner
      end
    end)
  end

  # TODO: Solve the issue with label and image data-attribute. (The issue is, that the data-attribute gets added to start and end tag)
  defp audit(rule, tag, acc) do
    regex = rule["regex"] |> String.replace(~r{tag}, tag)
    identifier = "data-audit-error" # rule["identifier"]

    Regex.scan(~r{#{regex}}, acc.content)
    |> Enum.reduce(acc, fn match, acc_inner ->
      appendError(identifier, match, rule, acc_inner)
    end)
  end

  defp auditLinking(rule, tag, acc) do
    regex = rule["regex"] |> String.replace(~r{tag}, tag)
    regex_get_link = rule["regex_get_link"]
    regex_check_link = rule["regex_check_link"]
    identifier = "data-audit-error" # rule["identifier"]

    Regex.scan(~r{#{regex}}, acc.content)
    |> Enum.reduce(acc, fn match, acc_inner ->
      linkId =
        case Regex.scan(~r{#{regex_get_link}}, Enum.at(match, 0)) do
          [[_, id | _]] -> id # Extract the correct part of the match
          _ -> ""
        end

      if linkId == "" do
        appendError(identifier, match, rule, acc_inner)
      else
        regex_check_link_with_id = Regex.replace(~r{refId}, regex_check_link, linkId)
        found_instances = Regex.scan(~r{#{regex_check_link_with_id}}, acc.content) |> Enum.count()
        if found_instances == 0 do
          appendError(identifier, match, rule, acc_inner)
        else
          acc_inner
        end
      end
    end)
  end

  defp update_state(result, _acc) do
    %{
      counter: result[:counter],
      matches: result[:matches],
      content: result[:content]
    }
  end

  defp appendError(identifier, match, rule, acc_inner) do
    if String.contains?(Enum.at(match, 0), "#{identifier}") do
      currentErrorIds =
        Regex.scan(~r{#{identifier}="([0-9,]+)"}, Enum.at(match, 0))
        |> Enum.at(0, 0)
        |> Enum.at(1, 0)
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      updated_data_attribute = "#{identifier}=\"#{Enum.join(currentErrorIds ++ [acc_inner.counter], ",")}\""
      updated_content = String.replace(Enum.at(match, 0), ~r{#{identifier}="([0-9,]+)"}, updated_data_attribute)
      content_without_identifier = String.replace(updated_content, ~r{(| )#{identifier}="([0-9,]+)"(| )}, "")

      concatinatedMatch = %{
        identifier: "#{identifier}",
        issue: rule["msg"],
        content: content_without_identifier,
        dataAttributeId: acc_inner.counter,
        contentWithIdentifier: updated_content,
        wcag: rule["wcag"],
        wcagClass: rule["wcagClass"],
        url: rule["url"],
        heading: rule["heading"],
        description: rule["description"],
        fixable: rule["fixable"]
      }

      update_state(
        %{
          counter: acc_inner.counter + 1,
          matches: acc_inner.matches ++ [concatinatedMatch],
          content: String.replace(acc_inner.content, Enum.at(match, 0), updated_content)
        }, acc_inner
      )
    else
      updated_content = String.replace(Enum.at(match, 0), ~r{(<[^\/>]*?)>}, "\\1 #{identifier}=\"#{acc_inner.counter}\">")
      content_without_identifier = String.replace(updated_content, ~r{(| )#{identifier}="([0-9,]+)"(| )}, "")

      concatinatedMatch = %{
        identifier: "#{identifier}",
        issue: rule["msg"],
        content: content_without_identifier,
        dataAttributeId: acc_inner.counter,
        contentWithIdentifier: updated_content,
        wcag: rule["wcag"],
        wcagClass: rule["wcagClass"],
        url: rule["url"],
        heading: rule["heading"],
        description: rule["description"],
        fixable: rule["fixable"]
      }

      update_state(
        %{
          counter: acc_inner.counter + 1,
          matches: acc_inner.matches ++ [concatinatedMatch],
          content: String.replace(acc_inner.content, Enum.at(match, 0), updated_content)
        }, acc_inner
      )
    end
  end

  defp addLineNumber(auditResult) do
    matches = auditResult.matches
    content = auditResult.content
    new_matches = Enum.map(matches, fn match ->
      lines = String.split(content, "\n")

      Enum.reduce_while(Enum.with_index(lines), match, fn {line, index}, acc ->
        if String.contains?(line, "data-audit-error") and String.contains?(line, Integer.to_string(match.dataAttributeId)) do
          {:halt, Map.put(acc, "lineIndex", index + 1)}
        else
          {:cont, acc}
        end
      end)
    end)
    %{success: true, html: content, numberOfErrors: auditResult.counter, matches: new_matches}
  end

end
