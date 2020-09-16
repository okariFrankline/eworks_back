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

  def render("assigned_order.json", %{assigned_order: order}) do
    %{
      data: %{
        assignee: render_one(order.assignee, __MODULE__, "assignee.json")
        is_assigned: order.is_assigned,
        description: order.descripiton,
        payable_amount: order.payable_amount,
        is_paid_for: order.is_paid_for
        payment_schedule: order.payment_schedule,
        category: order.category,
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

end # end of the module
