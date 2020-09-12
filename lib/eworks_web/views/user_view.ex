defmodule EworksWeb.UserView do
  use EworksWeb, :view
  alias EworksWeb.UserView

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
    %{id: user.id,
      email: user.email,
      password_hash: user.password_hash,
      is_active: user.is_active,
      user_type: user.user_type}
  end
end
