defmodule Katastr.AddressBook do
  alias Katastr.Record
  use GenServer

  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, %{}, opts)
  def init(_), do: {:ok, %{}}

  def check, do: GenServer.call(AddressBook, :check)
  def push(record = %Record{}), do: GenServer.cast(AddressBook, {:push, record})

  def handle_call(:check, _from, state) do
    sorted =
      state
      |> Map.values()
      |> Enum.sort_by(&{String.starts_with?(Enum.join(&1.plat_identifiers, ", "), "st"), &1.lv})

    {:reply, sorted, state}
  end

  def handle_cast({:push, record = %Record{}}, state) do
    new_state =
      state
      |> Map.update(Record.key(record), record, fn r ->
        concerned_properties = Enum.uniq(r.concerned_properties ++ record.concerned_properties)
        plat_identifiers =
          (r.plat_identifiers ++ record.plat_identifiers)
          |> Enum.sort(fn (p, _) -> String.starts_with?(p, "st") end)
          |> Enum.uniq()

        %{r | concerned_properties: concerned_properties, plat_identifiers: plat_identifiers}
      end)

    {:noreply, new_state}
  end
end
