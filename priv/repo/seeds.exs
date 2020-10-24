# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Eworks.Repo.insert!(%Eworks.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Eworks.Repo
alias Eworks.Accounts.{User, WorkProfile}
alias Eworks.Orders.{Order}
alias Eworks.Collaborations.{Invite, InviteOffer}
import Ecto.Query, warn: false

users = [
  %{email: "frankokari@gmail.com", full_name: "Frank Okari"},
  %{email: "ryanpaul@gmail.com", full_name: "Ryan Paul"},
  %{email: "donnanjeri@gmail.com", full_name: "Donna Njeri"},
  %{email: "kamaunjenga@gmail.com", full_name: "Kamau Njenga"},
  %{email: "byronnefrancis@gmail.com", full_name: "Byronne Francis"},
  %{email: "morrisnjenga@gmail.com", full_name: "Morris Njenga"},
  %{email: "faithchadianya@gamil.com", full_name: "Faith Chadianya"},
  %{email: "estherwambui@gmail.com", full_name: "Esther Wambui"},
  %{email: "peterkimani@gmail.com", full_name: "Peter Kimani"},
  %{email: "ericnjeri@gmail.com", full_name: "Eric Njeri"},
  %{email: "carolinekemunto@gmail.com", full_name: "Caroline Kemunto"},
  %{email: "phelisterobwangi@gmail.com", full_name: "Phelister Obwngi"}
]

roles = [
  "Client",
  "Independent Contractor"
]



created_users = Enum.map(users, fn user ->
  # get the role
  role = Enum.random(roles)
  # check the roles
  if role == "Client" do
    # create a user struct
    %User{
      auth_email: user.email,
      password_hash: Argon2.hash_pwd_salt("okari5678"),
      user_type: role,
      full_name: user.full_name,
      is_active: true,
      username: String.split(user.email, "@") |> List.first(),
    }
    # insert into the db
    |> Repo.insert!()

  else
    user = %User{
      auth_email: user.email,
      password_hash: Argon2.hash_pwd_salt("okari5678"),
      user_type: role,
      full_name: user.full_name,
      is_active: true,
      username: String.split(user.email, "@") |> List.first(),
    }
    # insert into the db
    |> Repo.insert!()

    # create a work profile for the user
    %WorkProfile{
      user_id: user.id,
      cover_letter: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
      professional_intro: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
      success_rate: 50.0,
      rating: 3.0,
      skills: ["IOS Developer", "Android Developer", "Events Planner"]
    }
    # insert to the db
    |> Repo.insert!()
    # return the user
    user
  end # end of if
end)

payment_schedules = [
  "At End of Contract",
  "Per Day",
  "Per Week",
  "Per Month"
]

description = "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run."

categories = [
  %{category: "Web and Software Development", specialty: "Mobile App Development"},
  %{category: "Music and Entertainment", specialty: "Event DJ and MC"},
  %{category: "Events and Event Planning", specialty: "Wedding Planning"},
  %{category: "Food and Catering", specialty: "Wedding Cake Baking Services"},
  %{category: "Construction and Construction Repairs", specialty: "Roofing Repairs"}
]


created_orders = Enum.map(0..20, fn _ ->
  user = Enum.random(created_users)
  category = Enum.random(categories)
  {:ok, date} = Date.from_iso8601("2020-10-20")
  %Order{
    user_id: user.id,
    description: description,
    deadline: date,
    payment_schedule: Enum.random(payment_schedules),
    payable_amount: "20000",
    category: category.category,
    specialty: category.specialty,
    is_verified: true,
    duration: "1 Week",
    required_contractors: 1,
    is_draft: false,
    owner_name: user.full_name,
    order_type: "One Time Order"
  }
  # insert the order
  |> Repo.insert!()
end) # end of each

first_10_orders = Enum.take(created_orders, 5)

first_10_ids = first_10_orders |> Enum.map(fn order -> order.id end)

# create the user
frank = %User{
  full_name: "Frankline Okari",
  auth_email: "okarifrankline1@gmail.com",
  user_type: "Independent Contractor",
  password_hash: Argon2.hash_pwd_salt("okari5678"),
  is_active: true,
  username: "okarifrankline1"
} |> Repo.insert!()

# create a work profile for the user
frank_profile = %WorkProfile{
  user_id: frank.id,
  cover_letter: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
  professional_intro: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
  success_rate: 50.0,
  rating: 3.0,
  skills: ["IOS Developer", "Android Developer", "Events Planner"],
  assigned_orders: first_10_ids
}
# insert to the db
|> Repo.insert!()

# get users who are independent contractors
user_type = "Independent Contractor"

users = from(
  user in User,
  where: user.user_type == ^user_type and user.id != ^frank.id,
  join: profile in assoc(user, :work_profile),
  preload: [work_profile: profile]
)
# get all the users
|> Repo.all()

# for the first 10 offers create invites
Enum.each(first_10_orders, fn order ->
  category = Enum.random(categories)
  user = Enum.random(users)
  # for each of the orders, make a collaboration offer
  {:ok, date} = Date.from_iso8601("2020-10-20")
  %Invite{
    order_id: order.id,
    work_profile_id: user.work_profile.id,
    category: category.category,
    specialty: category.specialty,
    payment_schedule: Enum.random(payment_schedules),
    payable_amount: "2000 - 3000",
    required_collaborators: 1,
    is_draft: false,
    description: description,
    deadline: date,
    owner_name: user.full_name
  }
  # inser the invite into the db
  |> Repo.insert!()
end)

# assign 10 orders to the user
invites = Enum.map(first_10_orders, fn order ->
  category = Enum.random(categories)
  # for each of the orders, make a collaboration offer
  {:ok, date} = Date.from_iso8601("2020-10-20")
  %Invite{
    order_id: order.id,
    work_profile_id: frank_profile.id,
    category: category.category,
    specialty: category.specialty,
    payment_schedule: Enum.random(payment_schedules),
    payable_amount: "2000 - 3000",
    required_collaborators: 1,
    is_draft: false,
    description: description,
    deadline: date,
    owner_name: frank.full_name
  }
  # inser the invite into the db
  |> Repo.insert!()
end)


# create at least 6 offers for each of the invites
Enum.each(invites, fn invite ->
  Enum.map(0..6, fn _ ->

    user = Enum.random(users)
    # create an invite offers
    %InviteOffer{
      invite_id: invite.id,
      user_id: user.id,
      asking_amount: 4000,
      owner_name: user.full_name,
      owner_about: user.work_profile.cover_letter,
      owner_rating: user.work_profile.rating,
      owner_job_success: user.work_profile.success_rate,
      owner_profile_pic: nil
    }
    # inser the offers
    |> Repo.insert!()
  end )
end)
