defmodule NewRelic.Utils do
  def elixir_environment() do
    build_info = System.build_info()

    [
      ["Language", "Elixir"],
      ["Elixir Version", build_info[:version]],
      ["OTP Version", build_info[:otp_release]],
      ["Elixir build", build_info[:build]]
    ]
  end

  def utilization() do
    %{
      hostname: hostname(),
      metadata_version: 3,
      logical_processors: :erlang.system_info(:logical_processors),
      total_ram_mib: get_system_memory()
    }
  end

  @mb 1_048_576
  defp get_system_memory() do
    case :memsup.get_system_memory_data()[:system_total_memory] do
      nil -> nil
      bytes -> trunc(bytes / @mb)
    end
  end

  def hostname() do
    {:ok, hostname} = :net_adm.dns_hostname(:net_adm.localhost())
    hostname
  end
end
