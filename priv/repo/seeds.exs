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



Enum.each(users, fn user ->
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
      success_rate: 50,
      rating: 3
    }
    # insert to the db
    |> Repo.insert!()
  end # end of if

end)
