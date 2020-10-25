defmodule EworksWeb.Requests.DirectHireView do
  use EworksWeb, :view
  alias EworksWeb.Orders.OrderView
  alias Eworks.API.Utils
  alias Eworks.Uploaders.ProfilePicture

  @doc """
    Render request.json
  """
  def render("request.json", %{request: request}) do
    %{
      data: %{
        order: render_one(request.order, OrderView, "order.json"),
        contractor: render_one(request.work_profile, __MODULE__, "contractor.json")
      }
    }
  end # end of request.json

  @doc """
    Render contractor.json
  """
  def render("contractor.json", %{direct_hire: profile}) do
    %{
      job_success: profile.success_rate,
      rating: profile.rating,
      about: profile.professional_intro,
      skills: profile.skills,
      show_more: profile.show_more,
      id: profile.user.id,
      full_name: profile.user.full_name,
      profile_pic: Utils.upload_url(ProfilePicture.url({profile.user.profile_pic, profile.user}, :thumb))
    }
  end # end of contractor.json

  @doc """
    Renders hire.json
  """
  def render("hire.json", %{direct_hire: hire, recipient: recipient, order: order}) do
    %{
      data: %{
        id: hire.id,
        is_rejected: hire.is_rejected,
        is_pending: hire.is_pending,
        created_on: Date.to_iso8601(hire.inserted_at),
        # the order for which this hire is for
        order: %{
          id: order.id,
          description: order.description,
          specialty: order.specialty,
          category: order.category
        },
        # the recipient of the direct hire
        recipient: render_one(recipient, __MODULE__, "recipient.json")
      }
    }
  end # end of hire.json

  @doc """
    Renders recipient.json
  """
  def render("recipient.json", %{direct_hire: recipient}) do
    %{
      full_name: recipient.full_name,
      id: recipient.id,
      rating: recipient.work_profile.rating,
      about: recipient.work_profile.professional_intro,
      job_success: recipient.work_profile.success_rate,
      profile_pic: Utils.upload_url(ProfilePicture.url({recipient.profile_pic, recipient}))
    }
  end # end of recipient.json

  @doc """
    Renders success.json
  """
  def render("success.json", %{message: message}) do
    %{
      data: %{
        success: true,
        details: message
      }
    }
  end # end of success.json

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
