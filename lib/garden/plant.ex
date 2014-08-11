defmodule Garden.Plant do
  @types %{
    tomato: %{emoji: "🍅", max_ripeness: 10, ideal_water: 10, seed_price: 99, sell_price: 199},
    potato: %{emoji: "🍠", max_ripeness: 15, ideal_water: 5, seed_price: 49, sell_price: 129},
    pumpkin: %{emoji: "🎃", max_ripeness: 20, ideal_water: 15, seed_price: 299, sell_price: 999},
  }
  @type_names Dict.keys(@types) |> Enum.map(&(Atom.to_string(&1)))
  @max_health 10

  def print_store do
    IO.puts Enum.map_join @types, "\n", fn({name, %{emoji: emoji, seed_price: seed_price}}) ->
      "#{emoji}  #{name} for #{Garden.Wallet.fmt_cash(seed_price)}"
    end
  end

  def start_link(type) when type in @type_names do
    Agent.start_link(fn ->
      state = Dict.get(@types, String.to_atom(type))
      |> Dict.put(:health, @max_health)
      |> Dict.put(:ripeness, 0)

      Dict.put(state, :water, Dict.get(state, :ideal_water))
    end)
  end
  def start_link(_invalid_type) do
    "Invalid plant type"
  end

  def plant_type(type) when type in @type_names do
    {:ok, Dict.get(@types, String.to_atom(type))}
  end
  def plant_type(_invalid_type) do
    {:error, "Invalid plant type"}
  end

  def name(pid) do
    Agent.get(pid, &(Dict.get(&1, :emoji)))
  end

  def sell_price(pid) do
    max = Agent.get(pid, &(Dict.get(&1, :sell_price)))
    health = Agent.get(pid, &(Dict.get(&1, :health)))
    price = max * (health / @max_health)

    case price do
      p when p > max -> max
      p              -> p
    end
  end

  def sellable?(pid) do
    health(pid) != "Dead!" and ripeness(pid) == "Ripe!"
  end

  def ripeness(pid) do
    Agent.get pid, fn(state) ->
      max_ripeness = Dict.get(state, :max_ripeness)

      case Dict.get(state, :ripeness) do
        r when r < max_ripeness * 0.25 -> "Budding"
        r when r < max_ripeness * 0.5  -> "Flowering"
        r when r < max_ripeness * 0.75 -> "Ripening..."
        r when r < max_ripeness        -> "Nearly ripe!"
        r when r < max_ripeness * 1.5  -> "Ripe!"
        _                              -> "Over-ripened!"
      end
    end
  end

  def health(pid) do
    Agent.get pid, fn(state) ->
      case Dict.get(state, :health) do
        h when h <= 0                 -> "Dead!"
        h when h < @max_health * 0.25 -> "Dying!"
        h when h < @max_health * 0.5  -> "Not doing well"
        h when h < @max_health * 0.75 -> "Could be better"
        h when h < @max_health        -> "Not too shabby"
        h when h >= @max_health       -> "Healthy!"
      end
    end
  end

  def thirst(pid) do
    ideal = Agent.get(pid, &(Dict.get(&1, :ideal_water)))

    Agent.get pid, fn(state) ->
      case Dict.get(state, :water) do
        w when w < ideal * 0.75 -> "Thirsty"
        w when w > ideal * 1.25 -> "Drowning"
        w                       -> "Watered"
      end
    end
  end

  def description(pid) do
    "#{__MODULE__.name(pid)}: [#{__MODULE__.ripeness(pid)}] [#{__MODULE__.health(pid)}] [#{__MODULE__.thirst(pid)}]"
  end

  def water(pid) do
    increment(pid, :water, 5)
  end

  def tick(pid) do
    update_health(pid)
    update_ripeness(pid)
    update_water(pid)
  end

  defp update_health(pid) do
    if !watered?(pid) or overripe?(pid) do
      decrement(pid, :health)
    else
      increment(pid, :health)
    end
  end

  defp update_ripeness(pid) do
    if watered?(pid) do
      increment(pid, :ripeness)
    end
  end

  defp update_water(pid) do
    decrement(pid, :water)
  end

  defp watered?(pid) do
    thirst(pid) == "Watered"
  end

  defp overripe?(pid) do
    ripeness(pid) == "Over-ripened!"
  end

  defp increment(pid, key, by \\ 1) do
    Agent.update(pid, &(Dict.put(&1, key, Dict.get(&1, key) + by)))
  end

  defp decrement(pid, key, by \\ 1) do
    increment(pid, key, -by)
  end
end
