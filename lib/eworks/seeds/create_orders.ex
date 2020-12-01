defmodule Eworks.Seeds.Orders do
  @moduledoc """
    Provides functions for the creation of orders to be used in the seeding of the database
  """
  alias Eworks.Repo
  alias Eworks.Orders.{Order}

  @doc """
    Provides sample payment schedules
  """
  def payment_schedules do
    [
      "At End of Contract",
      "Per Day",
      "Per Week",
      "Per Month"
    ]
  end

  @doc """
    Provides sample categories
  """
  def categories do
    [
      %{category: "Web and Software Development", specialty: "Mobile App Development"},
      %{category: "Music and Entertainment", specialty: "Event DJ and MC"},
      %{category: "Events and Event Planning", specialty: "Wedding Planning"},
      %{category: "Food and Catering", specialty: "Wedding Cake Baking Services"},
      %{category: "Construction and Construction Repairs", specialty: "Roofing Repairs"}
    ]
  end

  @doc """
    Description
  """
  def description do
    "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run."
  end

  @doc """
    Function for creating orders
  """
  def create_orders(owners) when is_list(owners) do
    Enum.map(0..20, fn _ ->
      # get a random owner
      user = Enum.random(owners)
      # assign a random category
      category = Enum.random(categories())
      # set the deadline for the order
      {:ok, date} = Date.from_iso8601("2020-10-20")

      %Order{
        user_id: user.id,
        description: description(),
        deadline: date,
        payment_schedule: Enum.random(payment_schedules()),
        payable_amount: "10000 - 15000",
        category: category.category,
        specialty: category.specialty,
        is_verified: true,
        duration: "1 Day - 1 Week",
        required_contractors: Enum.random(1..3),
        is_draft: false,
        owner_name: user.full_name,
        order_type: "One Time Project"
      }
      # insert the order
      |> Repo.insert!()
    end) # end of each
  end # end of create orders
end
