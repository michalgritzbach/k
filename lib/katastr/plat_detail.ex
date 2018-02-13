defmodule Katastr.PlatDetail do
  alias Katastr.Page
  use Hound.Helpers

  def get(ctn, plat_id, batch_identifier) do
    ProgressBar.render_spinner([frames: :braille, text: "Stahuji #{plat_id}…", done: [IO.ANSI.green, "✓", IO.ANSI.reset, " #{plat_id}"]], fn ->
      get_with_spinner(ctn, plat_id, batch_identifier)
    end)
  end

  defp get_with_spinner(ctn, plat_id, batch_identifier) do
    Hound.start_session()

    navigate_to("http://nahlizenidokn.cuzk.cz/VyberParcelu.aspx")

    fill_field({:name, "ctl00$bodyPlaceHolder$vyberObecKU$vyberKU$txtKU"}, ctn)

    click({:id, "ctl00_bodyPlaceHolder_vyberObecKU_vyberKU_btnKU"})

    click({:id, "ctl00_bodyPlaceHolder_druhCislovani_" <> plat_type(plat_id)})

    splitted =
      plat_id
      |> String.trim_leading("st")
      |> String.split("/", parts: 2)

    fill_field({:name, "ctl00$bodyPlaceHolder$txtParcis"}, List.first(splitted))

    if length(splitted) > 1 do
      fill_field({:name, "ctl00$bodyPlaceHolder$txtParpod"}, List.last(splitted))
    end

    click({:id, "ctl00_bodyPlaceHolder_btnVyhledat"})

    source = page_source()

    print_pdf(current_url(), plat_id, batch_identifier)

    Hound.end_session()

    %Page{plat_id: printable_plat_id(plat_id), html: source}
  end

  defp print_pdf(url, plat_id, batch_identifier) do
    case HPDF.print_pdf!(url, timeout: 15_000, after_load_delay: 4_000) do
      {:ok, pdf_data} -> save_pdf(pdf_data, plat_id, batch_identifier)
      {:error, error_type, reason} -> IO.puts("ERROR! #{error_type}, #{reason}")
      {:error, reason} -> IO.puts("ERROR – #{reason}")
    end
  end

  defp save_pdf(body, plat_id, batch_identifier) do
    # IO.inspect(batch_identifier)
    # IO.inspect(plat_id)
    # IO.inspect(body)
    # IO.puts("-----")

    :ok = File.mkdir_p(batch_identifier)
    plat_id = String.replace(plat_id, "/", "_")
    {:ok, file} = File.open("#{batch_identifier}/#{plat_id}.pdf", [:write])
    IO.binwrite(file, body)
    File.close(file)

    # IO.puts(File.read("#{batch_identifier}/#{plat_id}.pdf"))
  end

  defp plat_type("st" <> _), do: "0"
  defp plat_type(_), do: "1"

  defp printable_plat_id("st" <> plat_id) do
    "st. " <> String.trim_leading(plat_id, "st")
  end

  defp printable_plat_id(plat_id), do: plat_id
end
