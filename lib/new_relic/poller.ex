defmodule NewRelic.Poller do
  use GenServer
  require Logger

  ## API

  def start_link(poll_fun, error_cb \\ &default_error_cb/2) do
    GenServer.start_link(__MODULE__, %{poll_fun: poll_fun, error_cb: error_cb})
  end

  ## Callbacks

  def init(state) do
    :erlang.send_after(60000, self(), :poll)
    {:ok, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info(:poll, %{poll_fun: poll_fun, error_cb: error_cb} = state) do
    :erlang.send_after(60000, self(), :poll)
    {:ok, hostname} = :inet.gethostname()
    try do
      case poll_fun.() do
        {[], []} ->
          :ok
        {metrics, errors} ->
          NewRelic.Agent.push(hostname, metrics, errors)
      end
    rescue
      error -> error_cb.(:poll_failed, error)
    end

    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## Private functions

  defp default_error_cb(:poll_failed, err_msg) do
    Logger.warn("NewRelic.Poller: polling failed: #{inspect err_msg}")
  end
  defp default_error_cb(:push_failed, err_msg) do
    Logger.warn("NewRelic.Poller: push failed: #{inspect err_msg}")
  end

end
