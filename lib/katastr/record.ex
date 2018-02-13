defmodule Katastr.Record do
  alias Katastr.Record

  defstruct owner: "",
            lv: "",
            concerned_properties: [],
            plat_identifiers: [],
            portion: "",
            cadastral_territory: ""

  @doc """
  Generates an identifier based on Record's
  owner and potion of the land.

  ## Examples:

      iex> Katastr.Record.key(%Katastr.Record{owner: "Batman", portion: "1/1"})
      "QmF0bWFuLTEvMQ=="

  """
  def key(record = %Record{}), do: Base.encode64("#{record.owner}-#{record.portion}")

  def parse_owner(owner) do
    [city, street | rest] = owner |> String.split(", ") |> Enum.reverse()
    [zip | city] = String.split(city, " ")
    city = city |> Enum.join(" ")
    name = rest |> Enum.reverse() |> Enum.map_join(", ", &String.trim/1)

    %{
      zip: zip,
      city: city,
      street: street,
      name: name
    }
  end
end
