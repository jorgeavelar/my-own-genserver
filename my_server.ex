defmodule MyServer do
  require Logger

  def init(:ok) do
    0
  end

  def start do
    Server.start_link(__MODULE__)
  end

  def handle_info(message, state) do
    Logger.info("Got an unexpected message: #{inspect(message)} on state #{inspect(state)}")
    {:noreply, state}
  end

  def handle_call(:increment, _from, state) do
    {:reply, state, state + 1}
  end

  def handle_call(message, from, state) do
    Logger.info("Got a #{inspect(message)} from #{inspect(from)} on state #{inspect(state)}")
    {:noreply, state}
  end
end
