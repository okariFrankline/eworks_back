defmodule EworksWeb.ProfilesView do
  @moduledoc """
  Defines rendering functions for profiles
  """
  use EworksWeb, :view

  # user_profile.json
  def render("user_profile.json", %{user_profile: profile}) do
    %{

    }
  end

  # function for rendering the work_profile
  def render("work_profile", %{work_profile: profile}) do
    %{
      
    }
  end # end of the work_profile

end # end of the render profiles_view module
