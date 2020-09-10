defmodule Eworks.CollaborationsTest do
  use Eworks.DataCase

  alias Eworks.Collaborations

  describe "invites" do
    alias Eworks.Collaborations.Invite

    @valid_attrs %{collaborators_needed: 42, deadline: ~D[2010-04-17], is_paid_for: true, is_verified: true, payable_amount: "some payable_amount", title: "some title", verification_code: 42}
    @update_attrs %{collaborators_needed: 43, deadline: ~D[2011-05-18], is_paid_for: false, is_verified: false, payable_amount: "some updated payable_amount", title: "some updated title", verification_code: 43}
    @invalid_attrs %{collaborators_needed: nil, deadline: nil, is_paid_for: nil, is_verified: nil, payable_amount: nil, title: nil, verification_code: nil}

    def invite_fixture(attrs \\ %{}) do
      {:ok, invite} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Collaborations.create_invite()

      invite
    end

    test "list_invites/0 returns all invites" do
      invite = invite_fixture()
      assert Collaborations.list_invites() == [invite]
    end

    test "get_invite!/1 returns the invite with given id" do
      invite = invite_fixture()
      assert Collaborations.get_invite!(invite.id) == invite
    end

    test "create_invite/1 with valid data creates a invite" do
      assert {:ok, %Invite{} = invite} = Collaborations.create_invite(@valid_attrs)
      assert invite.collaborators_needed == 42
      assert invite.deadline == ~D[2010-04-17]
      assert invite.is_paid_for == true
      assert invite.is_verified == true
      assert invite.payable_amount == "some payable_amount"
      assert invite.title == "some title"
      assert invite.verification_code == 42
    end

    test "create_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collaborations.create_invite(@invalid_attrs)
    end

    test "update_invite/2 with valid data updates the invite" do
      invite = invite_fixture()
      assert {:ok, %Invite{} = invite} = Collaborations.update_invite(invite, @update_attrs)
      assert invite.collaborators_needed == 43
      assert invite.deadline == ~D[2011-05-18]
      assert invite.is_paid_for == false
      assert invite.is_verified == false
      assert invite.payable_amount == "some updated payable_amount"
      assert invite.title == "some updated title"
      assert invite.verification_code == 43
    end

    test "update_invite/2 with invalid data returns error changeset" do
      invite = invite_fixture()
      assert {:error, %Ecto.Changeset{}} = Collaborations.update_invite(invite, @invalid_attrs)
      assert invite == Collaborations.get_invite!(invite.id)
    end

    test "delete_invite/1 deletes the invite" do
      invite = invite_fixture()
      assert {:ok, %Invite{}} = Collaborations.delete_invite(invite)
      assert_raise Ecto.NoResultsError, fn -> Collaborations.get_invite!(invite.id) end
    end

    test "change_invite/1 returns a invite changeset" do
      invite = invite_fixture()
      assert %Ecto.Changeset{} = Collaborations.change_invite(invite)
    end
  end
end
