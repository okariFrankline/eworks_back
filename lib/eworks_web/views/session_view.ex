defmodule EworksWeb.SessionView do
  use EworksWeb, :view

  @doc """
    Renders logged in user
  """
  def render("logged_in.json", %{token: token, user: _user}) do
    # return the token
    %{
      data: %{
        token: token
      }
    }
  end # end of token
  
end
