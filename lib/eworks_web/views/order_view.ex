defmodule EworksWeb.OrderView do
  use EworksWeb, :view
  alias EworksWeb.OrderView


  # function of rendering a new order
  def render("new_order.json", %{new_order: order}) do
    %{
      data: %{
        id: order.id,
        description: order.description,
        specialty: order.specialty,
        category: order.category,
        attachments: upload_url(Eworks.Uploaders.OrderAttachment.url({order.attachments, order})),
        duration: order.duration,
        order_type: order.order_type,
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        is_verified: order.is_verified,
        deadline: Date.to_iso8601(order.deadline),
        required_contractors: order.required_contractors
      }
    }
  end

  # display_order.json sent only in the available offers page
  def render("display_order.json", %{order: order, owner: owner}) do
    %{
      id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      specialty: order.specialty,
      category: order.category,
      attachments: upload_url(Eworks.Uploaders.OrderAttachment.url({order.attachments, order})),
      duration: order.duration,
      order_type: order.order_type,
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      deadline: Date.to_iso8601(order.deadline),
      required_contractors: order.required_contractors,
      # owner of the order
      owner: %{
        id: owner.id,
        profile_pic: upload_url(Eworks.Uploaders.ProfilePicture.url({owner.profile_pic, owner})),
        full_name: owner.full_name
      }
    }
  end # end of display_order.json
  # order.json displayed only if the person requesting is the owner
  def render("order.json", %{order: order, offers: offers}) do
    %{
      data: %{
        id: order.id,
        description: order.description,
        is_verified: order.is_verified,
        is_assigned: order.is_assigned,
        is_complete: order.is_complete,
        is_paid_for: order.is_paid_for,
        accepted_offers: order.accepted_offers,
        specialty: order.specialty,
        category: order.category,
        offers_made: order.offers_made,
        attachments: upload_url(Eworks.Uploaders.OrderAttachment.url({order.attachments, order})),
        duration: order.duration,
        order_type: order.order_type,
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        deadline: Date.to_iso8601(order.deadline),
        required_contractors: order.required_contractors,
        # all the offers made for the order
        offers: render_many(offers, __MODULE__, "offer.json")
      }
    }
  end
  # offer.json
  def render("offer.json", %{offer: offer}) do
    %{
      id: offer.id,
      asking_amount: offer.asking_amount,
      is_accepted: offer.is_acepted,
      is_rejected: offer.is_rejected,
      is_cancelled: offer.is_cancelled,
      accepted_order: offer.accepted_order,
      # owner of the offer
      owner: %{
        id: offer.user.id,
        full_name: offer.user.full_name,
        rating: offer.user.work_profile.rating,
        prefessional_intro: offer.user.work_profile.professional_intro,
        profile_pic: upload_url(Eworks.Uploaders.ProfilePicture.url({offer.user.profile_pic, offer.user}))
      }
    }
  end

  def render("assigned_order.json", %{assigned_order: order, assignees: assignees}) do
    %{
      data: %{
        assignees: render_many(assignees, __MODULE__, "assignee.json"),
        is_assigned: order.is_assigned,
        description: order.descripiton,
        payable_amount: order.payable_amount,
        is_paid_for: order.is_paid_for,
        payment_schedule: order.payment_schedule,
        category: order.category,
        already_assigned: order.already_assigned,
        is_complete: order.is_complete
      }
    }
  end

  def render("assignee.json", %{assignee: assignee}) do
    %{
      id: assignee.id,
      full_name: assignee.full_name,
      rating: assignee.work_profile.rating,
      about: assignee.work_profile.professional_intro,
      asking_amount: assignee.order_offer.asking_amount,
      profile_pic: upload_url(Eworks.Uploaders.ProfilePicture.url({assignee.profile_pic, assignee}))
    }
  end

  def render("offers.json", %{accepted_offers: offers}) do
    %{
      data: %{
        order: render_one()
        accepted_offers: render_many(offers, __MODULE__, "offer.json")
      }
    }
  end



  def render("accepted_offer.json", %{accepted_offer: offer}) do
    %{
      data: %{
        accepted_offer: render_one(offer, __MODULE__, "offer.json"),
        order: %{
          id: offer.order.id,
          description: offer.order.description
        }
      }
    }
  end

  # succes render
  def render("success.json", _assigns) do
    %{
      data: %{
        success: true
      }
    }
  end

  defp upload_url(url) do
    if url, do: url |> String.split("?") |> List.first(), else: nil
  end # end of attachment_url

end # end of the module
