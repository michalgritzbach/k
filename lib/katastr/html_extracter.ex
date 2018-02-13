defmodule Katastr.HtmlExtracter do
  alias Katastr.Page
  alias Katastr.Record

  def parse(page = %Page{}) do
    {"td", _, [{"a", _, ct}]} = extract_from_td(page.html, "Katastrální území:")
    {"td", _, [{"a", _, lv}]} = extract_from_td(page.html, "Číslo LV")
    {"td", _, concerned_property} = extract_from_td(page.html, "Druh pozemku:")

    cadastral =
      ~r/\A(?<cadastral>[\w\W]+) \[(\d+)\]\z/
      |> Regex.named_captures(hd(ct))

    page.html
    |> extract_owners()
    |> Enum.map(fn {owner, portion} ->
      %Record{
        owner: owner,
        portion: portion,
        plat_identifiers: [page.plat_id],
        lv: hd(lv),
        concerned_properties: concerned_property,
        cadastral_territory: cadastral["cadastral"]
      }
    end)
  end

  defp extract_from_td(html, label) do
    html
    |> Floki.find(".atributySMapou td:fl-contains(\"#{label}\") + td")
    |> hd()
  end

  defp extract_owners(html) do
    html
    |> Floki.find("table.vlastnici tbody td")
    |> Enum.split_with(&(elem(&1, 1) == []))
    |> Tuple.to_list()
    |> Enum.zip()
    |> Enum.map(fn {{"td", _, owner}, {"td", _, portion}} ->
      {List.first(owner), List.first(portion)}
    end)
  end
end
