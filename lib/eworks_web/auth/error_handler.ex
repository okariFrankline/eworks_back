defmodule EworksWeb.Authentication.Guardian.ErrorHandler do
  use EworksWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> put_view(EworksWeb.ErrorView)
    |> render("unauthenticated.json")
  end
end # end of module
