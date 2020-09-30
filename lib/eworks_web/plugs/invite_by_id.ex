defmodule EworksWeb.Plugs.InviteById do
  @moduledoc """
    Gets an order based on a given id
  """
  @behaviour Plug
  import Plug.Conn

  alias Eworks.Collaborations

  # init function
  def init(opts), do: opts

  # call function
  def call(%{params: %{"invite_id" => id}} = conn, _opts) do
    invite = Collaborations.get_invite!(id)
    # put the order to the con assigns
    assign(conn, :invite, invite)
  rescue
    # no results were found
    Ecto.NoResultsError ->
      # put the 404 error
      conn
      # send a 404 error code
      |> send_resp(:not_found, "Collaboration Invite Not Found!")
      # halt the process
      |> halt()
  end # end of call/2

end # end of module
