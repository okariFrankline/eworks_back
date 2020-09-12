defmodule EworksWeb.WorkProfileView do
  use EworksWeb, :view
  alias EworksWeb.WorkProfileView

  def render("index.json", %{work_profiles: work_profiles}) do
    %{data: render_many(work_profiles, WorkProfileView, "work_profile.json")}
  end

  def render("show.json", %{work_profile: work_profile}) do
    %{data: render_one(work_profile, WorkProfileView, "work_profile.json")}
  end

  def render("work_profile.json", %{work_profile: work_profile}) do
    %{id: work_profile.id,
      rating: work_profile.rating,
      success_rate: work_profile.success_rate,
      skills: work_profile.skills,
      professional_intro: work_profile.professional_intro,
      job_hires: work_profile.job_hires}
  end
end
