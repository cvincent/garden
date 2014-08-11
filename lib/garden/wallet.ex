defmodule Garden.Wallet do
  def start_link do
    Agent.start_link(fn -> 1000 end, name: __MODULE__)
  end

  def print_cash do
    IO.puts "You have #{cash(Garden.Wallet)}"
  end

  def cash(pid) do
    fmt_cash(cents(pid))
  end

  def fmt_cash(amt) do
    "$#{amt / 100}"
  end

  def cents(pid) do
    Agent.get(pid, &(&1))
  end

  def add_cash(pid, amt) do
    Agent.update(pid, &(&1 + amt))
  end

  def subtract_cash(pid, amt) do
    if cents(pid) >= amt do
      add_cash(pid, -amt)
      {:ok, cents(pid)}
    else
      {:error, "Not enough money"}
    end
  end
end
