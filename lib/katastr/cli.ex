defmodule Katastr.CLI do
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating an
  Excel file with all the data
  """

  def main(argv) do
    argv
    |> parse_args()
    |> process()
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it's a cadastral territory number (ctn) followed
  by list of plat identificators (pi).

  Return a tuple of `{ctn, [pi1, pi2, …]}`, or `:help`, if help was given.
  """
  def parse_args(argv) do
    parse =
      OptionParser.parse(
        argv,
        switches: [help: :boolean],
        aliases: [h: :help]
      )

    case parse do
      {[help: true], _, _} -> :help
      {_, [ctn | pis], _} -> {ctn, pis}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts("""
    usage:  katastr <ctn> <pi1> <pi2> …
    """)

    System.halt(0)
  end

  def process({ctn, pis}) do
    {{y, m, d}, {h, min, s}} = :calendar.local_time()
    batch_identifier = "#{y}-#{m}-#{d}-#{h}-#{min}-#{s}"

    pis
    |> Enum.map(&Katastr.PlatDetail.get(ctn, &1, batch_identifier))
    |> Enum.flat_map(&Katastr.HtmlExtracter.parse/1)
    |> Enum.map(&Katastr.AddressBook.push/1)

    ProgressBar.render_spinner([frames: :braille, text: "Exportuji…", done: [IO.ANSI.green, "✓", IO.ANSI.reset, " Exportováno."]], fn ->
      export(Katastr.AddressBook.check(), batch_identifier)
    end)

    # IO.inspect(Katastr.AddressBook.check())
    System.halt(0)
  end

  def export(records, batch_identifier) do
    rows = Enum.map(records, &row/1)

    header = [
      "Jméno",
      "Ulice",
      "Město",
      "PSČ",
      "Dotčená nemovitost",
      "Parcela",
      "LV",
      "Podíl",
      "k. ú."
    ]



    %Elixlsx.Workbook{sheets: [%Elixlsx.Sheet{name: "List1", rows: [header] ++ rows}]}
    |> Elixlsx.write_to("#{batch_identifier}.xlsx")
  end

  def row(record) do
    owner = Katastr.Record.parse_owner(record.owner)

    [
      owner.name,
      owner.street,
      owner.city,
      owner.zip,
      Enum.join(record.concerned_properties, ", "),
      Enum.join(record.plat_identifiers, ", "),
      record.lv,
      record.portion,
      record.cadastral_territory
    ]
  end
end
