defmodule Eworks.AccountsTest do
  use Eworks.DataCase

  alias Eworks.Accounts

  describe "users" do
    alias Eworks.Accounts.User

    @valid_attrs %{email: "some email", is_active: true, password_hash: "some password_hash", user_type: "some user_type"}
    @update_attrs %{email: "some updated email", is_active: false, password_hash: "some updated password_hash", user_type: "some updated user_type"}
    @invalid_attrs %{email: nil, is_active: nil, password_hash: nil, user_type: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.is_active == true
      assert user.password_hash == "some password_hash"
      assert user.user_type == "some user_type"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.is_active == false
      assert user.password_hash == "some updated password_hash"
      assert user.user_type == "some updated user_type"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "profiles" do
    alias Eworks.Accounts.Profile

    @valid_attrs %{about: "some about", city: "some city", company_name: "some company_name", country: "some country", emails: [], first_name: "some first_name", last_name: "some last_name", phones: [], profile_pic: "some profile_pic"}
    @update_attrs %{about: "some updated about", city: "some updated city", company_name: "some updated company_name", country: "some updated country", emails: [], first_name: "some updated first_name", last_name: "some updated last_name", phones: [], profile_pic: "some updated profile_pic"}
    @invalid_attrs %{about: nil, city: nil, company_name: nil, country: nil, emails: nil, first_name: nil, last_name: nil, phones: nil, profile_pic: nil}

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Accounts.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Accounts.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = Accounts.create_profile(@valid_attrs)
      assert profile.about == "some about"
      assert profile.city == "some city"
      assert profile.company_name == "some company_name"
      assert profile.country == "some country"
      assert profile.emails == []
      assert profile.first_name == "some first_name"
      assert profile.last_name == "some last_name"
      assert profile.phones == []
      assert profile.profile_pic == "some profile_pic"
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Accounts.update_profile(profile, @update_attrs)
      assert profile.about == "some updated about"
      assert profile.city == "some updated city"
      assert profile.company_name == "some updated company_name"
      assert profile.country == "some updated country"
      assert profile.emails == []
      assert profile.first_name == "some updated first_name"
      assert profile.last_name == "some updated last_name"
      assert profile.phones == []
      assert profile.profile_pic == "some updated profile_pic"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_profile(profile, @invalid_attrs)
      assert profile == Accounts.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Accounts.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Accounts.change_profile(profile)
    end
  end
end
