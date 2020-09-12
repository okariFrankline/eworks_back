defmodule Eworks.Profile.User do
  @moduledoc """
    Defines a user to be used to the profile page
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    # has one work_profile
    has_one :user_profile, Eworks.Profiles.UserProfile
    # has one work profile
    has_one :work_profile, Ework.Profiles.WorkProfile
  end # end of the schema

end # end of the module
