defmodule Garden.CommandReader do
  @help """
  Avaialble commands:
  help        - Display this text
  look        - Display current money and plant status
  buy         - List plant seeds for sale
  buy [plant] - Buy a plant
  water [n]   - Give the numbered plant water
  sell [n]    - Sell the numbered plant
  remove [n]  - Remove the numbered plant
  """

  def start do
    Garden.Wallet.print_cash
    Garden.PlantSupervisor.print_plants
    read_command
  end

  def read_command do
    process_command(IO.gets("> ") |> String.split)
    read_command
  end

  defp process_command(["help"|_]) do
    IO.puts @help
  end
  defp process_command(["buy", plant_type]) do
    case Garden.PlantSupervisor.buy_plant(plant_type) do
      {:ok, plant}  -> IO.puts "Bought #{Garden.Plant.name(plant)}"
      {:error, err} -> IO.puts err
    end
  end
  defp process_command(["buy"|_]) do
    IO.puts "Available plants:"
    Garden.Plant.print_store
  end
  defp process_command(["sell", i]) do
    case Garden.PlantSupervisor.sell_plant(String.to_integer(i)) do
      {:ok, name, sell_price} -> IO.puts "Sold #{name}  for #{Garden.Wallet.fmt_cash(sell_price)}"
      {:error, err}           -> IO.puts err
    end
  end
  defp process_command(["remove", i]) do
    name = Garden.PlantSupervisor.plant(String.to_integer(i)) |> Garden.Plant.name
    Garden.PlantSupervisor.remove_plant(String.to_integer(i))
    IO.puts "Removed #{name}"
  end
  defp process_command(["look"]) do
    Garden.Wallet.print_cash
    Garden.PlantSupervisor.print_plants
  end
  defp process_command(["water", i]) do
    plant = Garden.PlantSupervisor.plant(String.to_integer(i))
    Garden.Plant.water(plant)
  end
  defp process_command(["quit"]) do
    # TODO: Figure this out
    Supervisor.stop(Garden)
  end
  defp process_command([]) do
  end
  defp process_command(_) do
    IO.puts "Unknown command"
  end
end
