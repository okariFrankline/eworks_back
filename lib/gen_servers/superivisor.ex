defmodule Eworks.Supervisor do
  @moduledoc false
  use Supervisor
  alias Eworks.Upgrade.Manager

  # start link
  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    children = [
      # set the manger
      {Manager, []}
    ]
    # initialize the manager upgrade
    Supervisor.init(children, strategy: :one_for_one)
  end

end # end of eworks superviosr
