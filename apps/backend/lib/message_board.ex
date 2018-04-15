defmodule MessageBoard do 
  use GenServer
  alias ElixirALE.GPIO

  #Client
  def start_link do
    state = %{messages: [], gpio_pid: nil}
    GenServer.start_link(__MODULE__, state)
  end

  def add(pid, message) do
    GenServer.cast(pid, message)
  end

  def view(pid) do
    GenServer.call(pid, :view)
  end

  #Server
  def init(%{messages: messages, gpio_pid: _pid})   do
    {:ok, pid} = GPIO.start_link(18, :output)
    {:ok, %{messages: messages, gpio_pid: pid} }
  end

  def handle_cast(message, %{messages: messages, gpio_pid: gpio_pid}) do
    updated_messages = [message|messages]
    GPIO.write(gpio_pid,1)
    :timer.sleep(2000)
    GPIO.write(gpio_pid,0)
    {:noreply, %{messages: updated_messages, gpio_pid: gpio_pid} }
  end

  def handle_call(:view, _from, messages) do
    {:reply, messages, messages}
  end
end
