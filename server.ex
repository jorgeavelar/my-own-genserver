defmodule Server do
  def call(pid, message) do
    send(pid, {:call, self(), message})
    receive do
      {:reply, reply} -> reply
      :noreply -> nil
      m -> raise "unexpected message: #{inspect(m)}"
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
    :ok
  end

  def start_link(module) do
    spawn fn ->
      handler(module, module.init(:ok))
    end
  end

  def handler(module, state) do
    receive do
      {:call, from, message} ->
        case module.handle_call(message, from, state) do
          {:reply, reply, new_state} ->
            send(from, {:reply, reply})
            handler(module, new_state)

          {:noreply, new_state} ->
            send(from, :noreply)
            handler(module, new_state)

          m ->
            send(from, {:unkown, m})
            handler(module, state)
        end

      other ->
        case module.handle_info(other, state) do
          {:noreply, new_state} ->
            handler(module, new_state)

          m ->
            raise "Invalid message #{inspect(m)}"
            handler(module, state)
        end
    end
  end
end
