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

  # render for the user_profile
  def render("user_profile.json", %{user_profile: profile}) do
    %{
      id: profile.id,
      city: profile.city,
      county: profile.country,
      emails: profile.emails,
      phones: profile.phones
    }
  end # end of the render for the user_profile.json

  # render the work profile
  def render("work_profile.json", %{work_profile: profile}) do
    %{
      id: profile.id,
      skills: profile.skills,
      professional_intro: profile.professional_intro,
      cover_letter: profile.cover_letter
    }
  end # end of the render for the work_profile.json
end
