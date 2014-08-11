defmodule Garden.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      supervisor(Garden.PlantSupervisor, [[name: Garden.PlantSupervisor]]),
      worker(Garden.Wallet, []),
      worker(Task, [Garden.CommandReader, :start, []], id: Garden.CommandReader),
      worker(Task, [Garden.Timer, :start, []], id: Garden.Timer)
    ]

    supervise(children, strategy: :one_for_one)
  end
end
