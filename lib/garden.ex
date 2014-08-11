defmodule Garden do
  use Application

  def start(_type, _args) do
    IO.puts("Welcome to your garden!")
    Garden.Supervisor.start_link
  end
end
