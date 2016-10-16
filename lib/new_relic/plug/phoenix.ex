defmodule NewRelic.Plug.Phoenix do
  @moduledoc """
  A plug that instruments Phoenix controllers and records their response times in New Relic.

  Inside an instrumented controller's actions, `conn` can be used for further instrumentation with
  `NewRelic.Plug.Instrumentation` and `NewRelic.Plug.Repo`.

  ```
  defmodule MyApp.UsersController do
    use Phoenix.Controller
    plug NewRelic.Plug.Phoenix

    def index(conn, _params) do
      # `conn` is setup for instrumentation
    end
  end
  ```
  """

  @behaviour Elixir.Plug
  import Elixir.Phoenix.Controller
  import Elixir.Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _config) do
    if NewRelic.configured? do
      module = conn |> controller_module |> Module.split |> List.last
      action = conn |> action_name |> Atom.to_string
      transaction_name = "#{module}##{action}"

      conn
      |> put_private(:new_relixir_transaction, NewRelic.Transaction.start(transaction_name))
      |> register_before_send(fn conn ->
        NewRelic.Transaction.finish(Map.get(conn.private, :new_relixir_transaction))

        conn
      end)
    else
      conn
    end
  end
end
