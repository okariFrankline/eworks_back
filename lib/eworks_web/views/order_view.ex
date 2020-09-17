defmodule EworksWeb.OrderView do
  use EworksWeb, :view
  alias EworksWeb.OrderView


  # function of rendering a new order
  def render("new_order.json", %{new_order: order}) do
    %{
      data: %{
        description: order.description,
        specialty: order.specialty,
        category: order.category,
        attachments: order.attachments,
        duration: order.duration,
        order_type: order.order_type,
        payment_schedule: order.payment_schedule,
        payable_amount: order.payable_amount,
        is_verified: order.is_verified,
        deadline: order.deadline,
        required_contractors: order.required_contractors
      }
    }
  end

  def render("order.json", %{order: order}) do
    %{id: order.id,
      description: order.description,
      is_verified: order.is_verified,
      is_assigned: order.is_assigned,
      is_complete: order.is_complete,
      is_paid_for: order.is_paid_for,
      description: order.description,
      specialty: order.specialty,
      category: order.category,
      offers_made: order.offers_made,
      attachments: order.attachments,
      duration: order.duration,
      order_type: order.order_type,
      payment_schedule: order.payment_schedule,
      payable_amount: order.payable_amount,
      deadline: order.deadline,
      required_contractors: order.required_contractors,
      # all the offers made for the order
      offers: order.offers
    }
  end

  def render("assigned_order.json", %{assigned_order: order, assignees: assignees}) do
    %{
      data: %{
        assignees: render_many(assignees, __MODULE__, "assignee.json")
        is_assigned: order.is_assigned,
        description: order.descripiton,
        payable_amount: order.payable_amount,
        is_paid_for: order.is_paid_for
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
      about: assignee.work_profile.professional_intro
      asking_amount: assignee.order_offer.asking_amount
      profile_pic: assignee.profile_pic
    }
  end

  def render("accepted_offers.json", %{accepted_offers: offers}) do
    %{
      data: %{
        accepted_offers: render_many(offers, __MODULE__, "offer.json")
      }
    }
  end

  def render("offer.json", %{offer: offer}) do
    %{
      id: offer.id,
      asking_amount: offer.asking_amount,
      is_accepted: offer.is_acepted,
      is_rejected: offer.is_rejected,
      is_cancelled: offer.is_cancelled,
      accepted_order: offer.accepted_order,
      owner: render_one(offer.user, __MODULE__, "offer_owner.json")
    }
  end

  def render("offer_owner.json", %{user: user}) do
    %{
      id: user.id
      full_name: user.full_name,
      rating: user.work_profile.rating,
      prefessional_intro: user.work_profile.professional_intro,
      profile_pic: user.profile_pic
    }
  end

  def render("accepted_offer.json", %{accepted_offer: offer}) do
    %{
      data: %{
        render_one(offer, __MODULE__, "offer.json"),
        order: %{
          id: offer.order.id,
          description: offer.order.description
        }
      }
    }
  end

end # end of the module
