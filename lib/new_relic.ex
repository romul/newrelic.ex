defmodule NewRelic do
  use Application

  @doc """
  Application callback to start NewRelic Agent.
  """
  @spec start(Application.app, Application.start_type) :: :ok | {:error, term}
  def start(_type \\ :normal, _args \\ []) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(:statman_sup, [[1000]]),
      worker(:statman_aggregator, []),
    ]

    opts = [strategy: :one_for_one, name: NewRelic.Supervisor]
    result = Supervisor.start_link(children, opts)

    :ok = :statman_server.add_subscriber(:statman_aggregator)

    with {:ok, _app_name} <- Application.fetch_env(:new_relic, :application_name),
         {:ok, _license_key} <- Application.fetch_env(:new_relic, :license_key) do
      {:ok, _} = NewRelic.Poller.start_link(&NewRelic.Statman.poll/0)
    else
      _ -> raise CompileError.message("Set :application_name and :license_key for :new_relic app")
    end

    result
  end

  @doc false
  @spec configured? :: boolean
  def configured? do
    Application.get_env(:new_relic, :application_name) != nil && Application.get_env(:new_relic, :license_key) != nil
  end
end
