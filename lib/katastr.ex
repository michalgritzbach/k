defmodule Katastr do
  @moduledoc """
  Documentation for Katastr.
  """

  use Hound.Helpers

  @doc """
  Hello world.
  """
  def hello do
    Hound.start_session()

    navigate_to("http://nahlizenidokn.cuzk.cz/VyberParcelu.aspx")

    el = find_element(:name, "ctl00$bodyPlaceHolder$vyberObecKU$vyberKU$txtKU")
    fill_field(el, "667455")

    click({:id, "ctl00_bodyPlaceHolder_vyberObecKU_vyberKU_btnKU"})

    :id
    |> find_element("ctl00_bodyPlaceHolder_druhCislovani_0")
    |> click()

    el = find_element(:name, "ctl00$bodyPlaceHolder$txtParcis")
    fill_field(el, "551")

    click({:id, "ctl00_bodyPlaceHolder_btnVyhledat"})

    # ctl00$bodyPlaceHolder$txtParpod

    IO.inspect(page_source(), limit: :inifnity, printable_limit: :infinity)

    Hound.end_session()

    :world
  end
end
