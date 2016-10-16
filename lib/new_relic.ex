defmodule NewRelic do
  use Application

  @doc """
  Application callback to start NewRelic Agent.
  """
  @spec start(Application.app, Application.start_type) :: :ok | {:error, term}
  def start(_type \\ :normal, _args \\ []) do
    import Supervisor.Spec, warn: false

    unless configured? do
      raise CompileError.message("Set :application_name and :license_key for :new_relic app")
    end

    children = [
      worker(NewRelic.Collector, []),
      worker(NewRelic.Poller, [&NewRelic.Statman.poll/0])
    ]

    opts = [strategy: :one_for_one, name: NewRelic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc false
  @spec configured? :: boolean
  def configured? do
    Application.get_env(:new_relic, :application_name) != nil && Application.get_env(:new_relic, :license_key) != nil
  end
end
