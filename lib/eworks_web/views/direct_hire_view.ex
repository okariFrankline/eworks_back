defmodule EworksWeb.DirectHireView do
  use EworksWeb, :view
  alias EworksWeb.DirectHireView

  def render("index.json", %{direct_hires: direct_hires}) do
    %{data: render_many(direct_hires, DirectHireView, "direct_hire.json")}
  end

  def render("show.json", %{direct_hire: direct_hire}) do
    %{data: render_one(direct_hire, DirectHireView, "direct_hire.json")}
  end

  def render("direct_hire.json", %{direct_hire: direct_hire}) do
    %{id: direct_hire.id,
      is_accepted: direct_hire.is_accepted,
      is_assigned: direct_hire.is_assigned}
  end
end
