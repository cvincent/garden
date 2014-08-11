defmodule Garden.PlantSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      worker(Garden.Plant, [], type: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def print_plants do
    IO.puts(plant_descriptions)
  end

  def plant_descriptions do
    Enum.map_join Enum.with_index(plants), "\n", fn({{_id, plant, _worker, _mod}, i}) ->
      "#{i + 1}) #{Garden.Plant.description(plant)}"
    end
  end

  def buy_plant(type) do
    case Garden.Plant.plant_type(type) do
      {:ok, plant_type} ->
        case Garden.Wallet.subtract_cash(Garden.Wallet, Dict.get(plant_type, :seed_price)) do
          {:ok, _amt}   -> add_plant(type)
          {:error, msg} -> {:error, msg}
        end
      {:error, msg} -> {:error, msg}
    end
  end

  def sell_plant(i) do
    p = plant(i)

    if Garden.Plant.sellable?(p) do
      name = Garden.Plant.name(p)
      sell_price = Garden.Plant.sell_price(p)
      Garden.Wallet.add_cash(Garden.Wallet, sell_price)
      remove_plant(i)
      {:ok, name, sell_price}
    else
      {:error, "Nobody wants to buy dead or unripened produce"}
    end
  end

  def add_plant(type) do
    Supervisor.start_child(__MODULE__, [type])
  end

  def remove_plant(i) do
    Supervisor.terminate_child(__MODULE__, plant(i))
  end

  def tick do
    Enum.each plants, fn({_id, plant, _worker, _mod}) ->
      Garden.Plant.tick(plant)
    end
    IO.puts("\n#{plant_descriptions}")
  end

  def plants do
    Supervisor.which_children(__MODULE__)
  end

  def plant(i) do
    {_id, plant, _worker, _mod} = Enum.at(plants, i - 1)
    plant
  end
end
