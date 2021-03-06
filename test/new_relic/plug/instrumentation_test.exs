defmodule NewRelic.Plug.InstrumentationTest do
  use ExUnit.Case, async: false
  import TestHelpers.Assertions
  import Plug.Conn
  require Ecto.Query

  alias NewRelic.Plug.Instrumentation

  defmodule FakeModel do
    use Ecto.Schema

    schema "fake_models" do
    end
  end

  @transaction_name "TestTransaction"

  setup do
    conn =
      %Plug.Conn{}
      |> put_private(:new_relixir_transaction, NewRelic.Transaction.start(@transaction_name))

    {:ok, conn: conn}
  end

  # query names

  test "instrument_db records elapsed time with correct key when given custom query string", %{
    conn: conn
  } do
    Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: conn, query: "TestQuery"], fn ->
      nil
    end)

    assert_contains(get_metric_keys(), {@transaction_name, {:db, "TestQuery"}})
  end

  test "instrument_db infers query name from instance of Ecto model and action name", %{
    conn: conn
  } do
    Instrumentation.instrument_db(:foo, %FakeModel{}, [conn: conn], fn -> nil end)
    assert_contains(get_metric_keys(), {@transaction_name, {:db, "FakeModel.foo"}})
  end

  test "instrument_db infers query name from module for Ecto model and action name", %{conn: conn} do
    Instrumentation.instrument_db(:foo, FakeModel, [conn: conn], fn -> nil end)
    assert_contains(get_metric_keys(), {@transaction_name, {:db, "FakeModel.foo"}})
  end

  test "instrument_db infers query name from Ecto changeset and action name", %{conn: conn} do
    changeset = Ecto.Changeset.cast(%FakeModel{}, %{}, [], [])
    Instrumentation.instrument_db(:foo, changeset, [conn: conn], fn -> nil end)
    assert_contains(get_metric_keys(), {@transaction_name, {:db, "FakeModel.foo"}})
  end

  test "instrument_db infers query name from query on an Ecto model", %{conn: conn} do
    query = Ecto.Query.from(FakeModel)
    Instrumentation.instrument_db(:foo, query, [conn: conn], fn -> nil end)
    assert_contains(get_metric_keys(), {@transaction_name, {:db, "FakeModel.foo"}})
  end

  test "instrument_db records query as SQL when query name can't be determined", %{conn: conn} do
    Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: conn], fn -> nil end)
    assert_contains(get_metric_keys(), {@transaction_name, {:db, "SQL"}})
  end

  # with transaction

  test "instrument_db records accurate elapsed time", %{conn: conn} do
    {_, elapsed_time} =
      :timer.tc(fn ->
        Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: conn], fn ->
          :ok = :timer.sleep(42)
        end)
      end)

    [recorded_time] = get_metric_by_key({@transaction_name, {:db, "SQL"}})
    assert_between(recorded_time, 42000, elapsed_time)
  end

  test "instrument_db returns value of instrumented function", %{conn: conn} do
    return_value =
      Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: conn], fn ->
        42
      end)

    assert return_value == 42
  end

  # with no transaction

  test "instrument_db does not record elapsed time when transaction is not present" do
    Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: %Plug.Conn{}], fn -> nil end)
    assert Enum.empty?(get_metric_keys())
  end

  test "instrument_db returns value of instrumented function when transaction is not present" do
    return_value =
      Instrumentation.instrument_db(:foo, %Ecto.Query{}, [conn: %Plug.Conn{}], fn ->
        42
      end)

    assert return_value == 42
  end
end
