defmodule EworksWeb.Plugs.OrderById do
  @moduledoc """
    Gets an order based on a given id
  """
  @behaviour Plug
  import Plug.Conn

  alias Eworks.Orders

  # init function
  def init(opts), do: opts

  # call function
  def call(%{params: %{"order_id" => id}} = conn, _opts) do
    order = Orders.get_order!(id)
    # put the order to the con assigns
    assign(conn, :order, order)
  rescue
    # no results were found
    Ecto.NoResultsError ->
      # put the 404 error
      conn
      # send a 404 error code
      |> send_resp(:not_found, " ")
      # halt the process
      |> halt()
  end # end of call/2

end # end of module
