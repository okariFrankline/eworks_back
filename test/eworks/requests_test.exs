defmodule Eworks.RequestsTest do
  use Eworks.DataCase

  alias Eworks.Requests

  describe "direct_hires" do
    alias Eworks.Requests.DirectHire

    @valid_attrs %{is_accepted: true, is_assigned: true}
    @update_attrs %{is_accepted: false, is_assigned: false}
    @invalid_attrs %{is_accepted: nil, is_assigned: nil}

    def direct_hire_fixture(attrs \\ %{}) do
      {:ok, direct_hire} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Requests.create_direct_hire()

      direct_hire
    end

    test "list_direct_hires/0 returns all direct_hires" do
      direct_hire = direct_hire_fixture()
      assert Requests.list_direct_hires() == [direct_hire]
    end

    test "get_direct_hire!/1 returns the direct_hire with given id" do
      direct_hire = direct_hire_fixture()
      assert Requests.get_direct_hire!(direct_hire.id) == direct_hire
    end

    test "create_direct_hire/1 with valid data creates a direct_hire" do
      assert {:ok, %DirectHire{} = direct_hire} = Requests.create_direct_hire(@valid_attrs)
      assert direct_hire.is_accepted == true
      assert direct_hire.is_assigned == true
    end

    test "create_direct_hire/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Requests.create_direct_hire(@invalid_attrs)
    end

    test "update_direct_hire/2 with valid data updates the direct_hire" do
      direct_hire = direct_hire_fixture()
      assert {:ok, %DirectHire{} = direct_hire} = Requests.update_direct_hire(direct_hire, @update_attrs)
      assert direct_hire.is_accepted == false
      assert direct_hire.is_assigned == false
    end

    test "update_direct_hire/2 with invalid data returns error changeset" do
      direct_hire = direct_hire_fixture()
      assert {:error, %Ecto.Changeset{}} = Requests.update_direct_hire(direct_hire, @invalid_attrs)
      assert direct_hire == Requests.get_direct_hire!(direct_hire.id)
    end

    test "delete_direct_hire/1 deletes the direct_hire" do
      direct_hire = direct_hire_fixture()
      assert {:ok, %DirectHire{}} = Requests.delete_direct_hire(direct_hire)
      assert_raise Ecto.NoResultsError, fn -> Requests.get_direct_hire!(direct_hire.id) end
    end

    test "change_direct_hire/1 returns a direct_hire changeset" do
      direct_hire = direct_hire_fixture()
      assert %Ecto.Changeset{} = Requests.change_direct_hire(direct_hire)
    end
  end
end
