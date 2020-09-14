defmodule EworksWeb.ProfileView do
  use EworksWeb, :view
  alias EworksWeb.ProfileView

  def render("index.json", %{profiles: profiles}) do
    %{data: render_many(profiles, ProfileView, "profile.json")}
  end

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile}) do
    %{id: profile.id,
      first_name: profile.first_name,
      last_name: profile.last_name,
      company_name: profile.company_name,
      country: profile.country,
      city: profile.city,
      emails: profile.emails,
      phones: profile.phones,
      about: profile.about,
      profile_pic: profile.profile_pic}
  end

  def render("user_profile.json", %{profile: profile}) do
    %{
      id: profile.id
    }
  end
end
