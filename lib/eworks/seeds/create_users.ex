defmodule Eworks.Seeds.Users do
  @moduledoc """
    Provides functions for creating new users for seeding the database
  """
  alias Eworks.Accounts.{User, WorkProfile}
  alias Eworks.Repo

  @doc """
    Provides the smaple data for creating the users
  """
  def client_user_data do
    [
      %{email: "paulnjoroge@gmail.com", full_name: "Njoroge Paul"},
      %{email: "ryanpaul@gmail.com", full_name: "Ryan Paul"},
      %{email: "dianaprincess@gmail.com", full_name: "Princess Diana"},
      %{email: "kamaunjenga@gmail.com", full_name: "Kamau Njenga"},
    ]
  end # end of user data

  def contractor_user_data do
    [
      %{email: "byronnefrancis@gmail.com", full_name: "Byronne Francis"},
      %{email: "morrisnjenga@gmail.com", full_name: "Morris Njenga"},
      %{email: "faithchadianya@gamil.com", full_name: "Faith Chadianya"},
      %{email: "estherwambui@gmail.com", full_name: "Esther Wambui"},
      %{email: "peterkimani@gmail.com", full_name: "Peter Kimani"},
      %{email: "ericnjeri@gmail.com", full_name: "Eric Njeri"},
      %{email: "carolinekemunto@gmail.com", full_name: "Caroline Kemunto"},
      %{email: "phelisterobwangi@gmail.com", full_name: "Phelister Obwngi"},
      %{email: "okarifrankline1@gmail.com", full_name: "Frankline Okari"}
    ]
  end

  @doc """
    Function for creating contractors
  """
  def create_contractors do
    Enum.each(contractor_user_data(), fn user ->
      user = %User{
        auth_email: user.email,
        password_hash: Argon2.hash_pwd_salt("okari5678"),
        user_type: "Independent Contractor",
        full_name: user.full_name,
        is_active: true,
        username: String.split(user.email, "@") |> List.first(),
      }
      # insert into the db
      |> Repo.insert!()

      # create a work profile for the user
      %WorkProfile{
        user_id: user.id,
        #cover_letter: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
        professional_intro: "Not too bad! We grab our loader and load a batch exactly like we were doing in IEx previously. New to the helper team is on_load , which we’re importing from Absinthe.Resolution.Helpers . The callback function we pass to on_load is a lot like the callback function we pass to the batch helper. Similar to batch , on_load hands off control to the Absinthe.Middleware.Dataloader module, which arranges to run our callback after the Dataloader batches have been run.",
        success_rate: 50.0,
        rating: 3.0,
        skills: ["IOS Developer", "Android Developer", "Events Planner"]
      }
      # insert to the db
      |> Repo.insert!()
    end)
  end

  @doc """
    Function for creating clients
  """
  def create_clients do
    # returns a list of users
    Enum.map(client_user_data(), fn user ->
      # create a user struct
      %User{
        auth_email: user.email,
        password_hash: Argon2.hash_pwd_salt("okari5678"),
        user_type: "Client",
        full_name: user.full_name,
        is_active: true,
        profile_complete: true,
        username: String.split(user.email, "@") |> List.first(),
      }
      # insert into the db
      |> Repo.insert!()
    end)
  end


end # end of the module
