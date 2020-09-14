defmodule EworksWeb.UserView do
  use EworksWeb, :view
  alias EworksWeb.{UserView, ProfilesView}

  # new user.json
  def render("new_user.json", %{user: user, token: token}) do
    # retrun the result
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json"),
        token: token
      }
    }
  end # end of the new_user.json

  # logged_in.json
  def render("activated.json", %{user: user}) do
    # return the data
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json"),
        user_profile: render_one(user.profile, ProfilesView, "profile.json")
      }
    }
  end # end of logged_in.json

  # logged_in.json
  def render("logged_in.json", %{user: user, token: token}) do
    # return the data
    %{
      data: %{
        user: render_one(user, __MODULE__, "user.json"),
        user_profile: render_one(user.profile, ProfilesView, "profile.json"),
        token: token
      }
    }
  end # end of logged_in.json

  # new_user.json
  def render("index.json", %{user: user}) do
    # return the data
    %{data: %{
      user_id: user.id,
      email: user.auth_email
    }}
  end # end of the index.json

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    # return the user's firstname, last name and is active
    %{
      name: user.full_name
      is_active: user.is_active
    }
  end
end # end of the module
