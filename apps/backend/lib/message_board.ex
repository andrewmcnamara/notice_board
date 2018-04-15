defmodule MessageBoard do 
  use GenServer
  alias ExLCD
  
  lcd_config  %{ rs: 25, en: 24, d4: 17, d5: 22, d6: 23, d7: 18, rows: 2, cols: 20, font_5x10: false }


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
    {:ok, pid} = ExLCD.start_link({ExLCD.HD44780, @lcd_config})
    ExLCD.enable(:display)
    {:ok, %{messages: messages, gpio_pid: pid} }
  end

  def handle_cast(message, %{messages: messages, gpio_pid: gpio_pid}) do
    updated_messages = [message|messages]
    ExLCD.write(message)
    {:noreply, %{messages: updated_messages, gpio_pid: gpio_pid} }
  end

  def handle_call(:view, _from, messages) do
    {:reply, messages, messages}
  end
end
