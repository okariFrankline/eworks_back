defmodule Eworks.ProfilesTest do
  use Eworks.DataCase

  alias Eworks.Profiles

  describe "work_profiles" do
    alias Eworks.Profiles.WorkProfile

    @valid_attrs %{job_hires: 42, professional_intro: "some professional_intro", rating: 42, skills: [], success_rate: 42}
    @update_attrs %{job_hires: 43, professional_intro: "some updated professional_intro", rating: 43, skills: [], success_rate: 43}
    @invalid_attrs %{job_hires: nil, professional_intro: nil, rating: nil, skills: nil, success_rate: nil}

    def work_profile_fixture(attrs \\ %{}) do
      {:ok, work_profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profiles.create_work_profile()

      work_profile
    end

    test "list_work_profiles/0 returns all work_profiles" do
      work_profile = work_profile_fixture()
      assert Profiles.list_work_profiles() == [work_profile]
    end

    test "get_work_profile!/1 returns the work_profile with given id" do
      work_profile = work_profile_fixture()
      assert Profiles.get_work_profile!(work_profile.id) == work_profile
    end

    test "create_work_profile/1 with valid data creates a work_profile" do
      assert {:ok, %WorkProfile{} = work_profile} = Profiles.create_work_profile(@valid_attrs)
      assert work_profile.job_hires == 42
      assert work_profile.professional_intro == "some professional_intro"
      assert work_profile.rating == 42
      assert work_profile.skills == []
      assert work_profile.success_rate == 42
    end

    test "create_work_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_work_profile(@invalid_attrs)
    end

    test "update_work_profile/2 with valid data updates the work_profile" do
      work_profile = work_profile_fixture()
      assert {:ok, %WorkProfile{} = work_profile} = Profiles.update_work_profile(work_profile, @update_attrs)
      assert work_profile.job_hires == 43
      assert work_profile.professional_intro == "some updated professional_intro"
      assert work_profile.rating == 43
      assert work_profile.skills == []
      assert work_profile.success_rate == 43
    end

    test "update_work_profile/2 with invalid data returns error changeset" do
      work_profile = work_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_work_profile(work_profile, @invalid_attrs)
      assert work_profile == Profiles.get_work_profile!(work_profile.id)
    end

    test "delete_work_profile/1 deletes the work_profile" do
      work_profile = work_profile_fixture()
      assert {:ok, %WorkProfile{}} = Profiles.delete_work_profile(work_profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_work_profile!(work_profile.id) end
    end

    test "change_work_profile/1 returns a work_profile changeset" do
      work_profile = work_profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_work_profile(work_profile)
    end
  end

  describe "user_profiles" do
    alias Eworks.Profiles.UserProfile

    @valid_attrs %{cit: "some cit", company_name: "some company_name", country: "some country", emails: [], first_name: "some first_name", last_name: "some last_name", phones: [], profile_pic: "some profile_pic"}
    @update_attrs %{cit: "some updated cit", company_name: "some updated company_name", country: "some updated country", emails: [], first_name: "some updated first_name", last_name: "some updated last_name", phones: [], profile_pic: "some updated profile_pic"}
    @invalid_attrs %{cit: nil, company_name: nil, country: nil, emails: nil, first_name: nil, last_name: nil, phones: nil, profile_pic: nil}

    def user_profile_fixture(attrs \\ %{}) do
      {:ok, user_profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profiles.create_user_profile()

      user_profile
    end

    test "list_user_profiles/0 returns all user_profiles" do
      user_profile = user_profile_fixture()
      assert Profiles.list_user_profiles() == [user_profile]
    end

    test "get_user_profile!/1 returns the user_profile with given id" do
      user_profile = user_profile_fixture()
      assert Profiles.get_user_profile!(user_profile.id) == user_profile
    end

    test "create_user_profile/1 with valid data creates a user_profile" do
      assert {:ok, %UserProfile{} = user_profile} = Profiles.create_user_profile(@valid_attrs)
      assert user_profile.cit == "some cit"
      assert user_profile.company_name == "some company_name"
      assert user_profile.country == "some country"
      assert user_profile.emails == []
      assert user_profile.first_name == "some first_name"
      assert user_profile.last_name == "some last_name"
      assert user_profile.phones == []
      assert user_profile.profile_pic == "some profile_pic"
    end

    test "create_user_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_user_profile(@invalid_attrs)
    end

    test "update_user_profile/2 with valid data updates the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, %UserProfile{} = user_profile} = Profiles.update_user_profile(user_profile, @update_attrs)
      assert user_profile.cit == "some updated cit"
      assert user_profile.company_name == "some updated company_name"
      assert user_profile.country == "some updated country"
      assert user_profile.emails == []
      assert user_profile.first_name == "some updated first_name"
      assert user_profile.last_name == "some updated last_name"
      assert user_profile.phones == []
      assert user_profile.profile_pic == "some updated profile_pic"
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user_profile = user_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_user_profile(user_profile, @invalid_attrs)
      assert user_profile == Profiles.get_user_profile!(user_profile.id)
    end

    test "delete_user_profile/1 deletes the user_profile" do
      user_profile = user_profile_fixture()
      assert {:ok, %UserProfile{}} = Profiles.delete_user_profile(user_profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_user_profile!(user_profile.id) end
    end

    test "change_user_profile/1 returns a user_profile changeset" do
      user_profile = user_profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_user_profile(user_profile)
    end
  end
end
