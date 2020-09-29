defmodule Eworks.Loaders.Dataloader do
  @moduledoc """
    Defines the loaders for getting the data
  """
  alias Eworks.{Repo, Accounts, Orders}

  def source, do: Dataloader.Ecto.new(Repo)

  def data_loader() do
    # create a new dataloader
    Dataloader.new
    # add the Orders context
    |> Dataloader.add_source(Orders, source())
    # add the Accounts source
    |> Dataloader.add_source(Accounts, source())
  end # end of getting the dataloadder

end # end of dataloader module
