defmodule EworksWeb.Plugs.IsActive do
  @moduledoc """
    Ensures that the user is active
  """
  @behaviour Plug
  import Plug.Conn


  # init function
  def init(opts),  do: opts


  # call function
  def call(%{assigns: %{current_user: user}} = conn, _opts) do
    # ensure the user is active
    if user.is_active do
      # return the conn
      conn
    else
      # the user is not active
      conn
      # put the error vie
      |> put_status(:unauthorized)
      # put the error view
      |> Phoenix.Controller.put_view(EworksWeb.ErrorView)
      # render the is_not active json
      |> Phoenix.Controller.render("not_active.json")
      # halt the processing of oconn
      |> halt()
    end # end of checking if the user is logged in

  end
end
