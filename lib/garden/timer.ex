defmodule Garden.Timer do
  @tick 5000

  def start do
    tick
  end

  def tick do
    :timer.sleep(@tick)
    Garden.PlantSupervisor.tick
    tick
  end
end
