defmodule HelloWeb.Audit do
  def doAudit(rules, content) do
    initial_state = %{counter: 0, matches: [], content: content}

    Enum.reduce(rules, initial_state, fn rule, acc ->
      # internalHierarchy
      internalHierarchy = if rule["rule_type"] == "internal hierarchy" do
        Enum.reduce(rule["tags"], acc, fn tag, acc_inner ->
          auditInternalHierarchy(rule, tag, acc_inner)
        end)
      else
        acc
      end

      # linking
      auditLinking = if rule["rule_type"] == "linking" do
        Enum.reduce(rule["tags"], internalHierarchy, fn tag, acc_inner ->
          auditLinking(rule, tag, acc_inner)
        end)
      else
        acc
      end

      # rules without specific type
      auditResult = if rule["rule_type"] == nil do
        Enum.reduce(rule["tags"], auditLinking, fn tag, acc_inner ->
          audit(rule, tag, acc_inner)
        end)
      else
        internalHierarchy
      end
      auditResult
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
        if String.contains?(Enum.at(match, 0), "#{identifier}") do
          updated_content = String.replace(Enum.at(match, 0), ~r{[0-9,]+}, fn current ->
            current_in_array = String.split(current, ",") |> Enum.map(&String.to_integer/1)
            Enum.join(current_in_array ++ [acc_inner.counter], ",")
          end)

          concatinatedMatch = %{
            identifier: "#{identifier}",
            issue: rule["msg"],
            content: Enum.at(match, 0),
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

          concatinatedMatch = %{
            identifier: "#{identifier}",
            issue: rule["msg"],
            content: Enum.at(match, 0),
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
      else
        acc_inner
      end
    end)
  end

  # TODO: Add image stuff
  defp audit(rule, tag, acc) do
    regex = rule["regex"] |> String.replace(~r{tag}, tag)
    identifier = "data-audit-error" # rule["identifier"]

    Regex.scan(~r{#{regex}}, acc.content)
    |> Enum.reduce(acc, fn match, acc_inner ->
      if String.contains?(Enum.at(match, 0), identifier) do
        updated_content = String.replace(Enum.at(match, 0), ~r{[0-9,]+}, fn current ->
          current_in_array = String.split(current, ",") |> Enum.map(&String.to_integer/1)
          Enum.join(current_in_array ++ [acc_inner.counter], ",")
        end)

        concatinatedMatch = %{
          identifier: "#{identifier}",
          issue: rule["msg"],
          content: Enum.at(match, 0),
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
        updated_content = String.replace(Enum.at(match, 0), ~r{(<[^\/>]*?)>}, "\\1 data-audit-error=\"#{acc_inner.counter}\">")

        concatinatedMatch = %{
          identifier: identifier,
          issue: rule["msg"],
          content: Enum.at(match, 0),
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
    end)
  end

  defp auditLinking(rule, tag, acc) do
    regex = rule["regex"] |> String.replace(~r{tag}, tag)
    identifier = "data-audit-error" # rule["identifier"]

    Regex.scan(~r{#{regex}}, acc.content)
    |> Enum.reduce(acc, fn match, acc_inner ->

      # TODO: Something is wrong. The linkId is not being set correctly (cause not only the label is "linking")
      linkId = String.split(Enum.at(match, 0), "for=\"") |> Enum.at(1) |> String.split("\"") |> Enum.at(0)
      if linkId != "" and !String.match?(Enum.at(match, 0), ~r{/[^<>]*?/}) do
        if String.contains?(Enum.at(match, 0), identifier) do
          updated_content = String.replace(Enum.at(match, 0), ~r{[0-9,]+}, fn current ->
            current_in_array = String.split(current, ",") |> Enum.map(&String.to_integer/1)
            Enum.join(current_in_array ++ [acc_inner.counter], ",")
          end)

          concatinatedMatch = %{
            identifier: identifier,
            issue: rule["msg"],
            content: Enum.at(match, 0),
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
          updated_content = String.replace(Enum.at(match, 0), ~r{(<[^\/>]*?)>}, "\\1 data-audit-error=\"#{acc_inner.counter}\">")

          concatinatedMatch = %{
            identifier: identifier,
            issue: rule["msg"],
            content: Enum.at(match, 0),
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
      else
        acc
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
    %{content: content, errorNumber: auditResult.counter, matches: new_matches}
  end

end
