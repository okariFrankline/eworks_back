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

  describe "invite_offers" do
    alias Eworks.Collaborations.InviteOffer

    @valid_attrs %{asking_amount: 42, is_accepted: true, is_cancelled: true, is_pending: true, is_rejected: true}
    @update_attrs %{asking_amount: 43, is_accepted: false, is_cancelled: false, is_pending: false, is_rejected: false}
    @invalid_attrs %{asking_amount: nil, is_accepted: nil, is_cancelled: nil, is_pending: nil, is_rejected: nil}

    def invite_offer_fixture(attrs \\ %{}) do
      {:ok, invite_offer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Collaborations.create_invite_offer()

      invite_offer
    end

    test "list_invite_offers/0 returns all invite_offers" do
      invite_offer = invite_offer_fixture()
      assert Collaborations.list_invite_offers() == [invite_offer]
    end

    test "get_invite_offer!/1 returns the invite_offer with given id" do
      invite_offer = invite_offer_fixture()
      assert Collaborations.get_invite_offer!(invite_offer.id) == invite_offer
    end

    test "create_invite_offer/1 with valid data creates a invite_offer" do
      assert {:ok, %InviteOffer{} = invite_offer} = Collaborations.create_invite_offer(@valid_attrs)
      assert invite_offer.asking_amount == 42
      assert invite_offer.is_accepted == true
      assert invite_offer.is_cancelled == true
      assert invite_offer.is_pending == true
      assert invite_offer.is_rejected == true
    end

    test "create_invite_offer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Collaborations.create_invite_offer(@invalid_attrs)
    end

    test "update_invite_offer/2 with valid data updates the invite_offer" do
      invite_offer = invite_offer_fixture()
      assert {:ok, %InviteOffer{} = invite_offer} = Collaborations.update_invite_offer(invite_offer, @update_attrs)
      assert invite_offer.asking_amount == 43
      assert invite_offer.is_accepted == false
      assert invite_offer.is_cancelled == false
      assert invite_offer.is_pending == false
      assert invite_offer.is_rejected == false
    end

    test "update_invite_offer/2 with invalid data returns error changeset" do
      invite_offer = invite_offer_fixture()
      assert {:error, %Ecto.Changeset{}} = Collaborations.update_invite_offer(invite_offer, @invalid_attrs)
      assert invite_offer == Collaborations.get_invite_offer!(invite_offer.id)
    end

    test "delete_invite_offer/1 deletes the invite_offer" do
      invite_offer = invite_offer_fixture()
      assert {:ok, %InviteOffer{}} = Collaborations.delete_invite_offer(invite_offer)
      assert_raise Ecto.NoResultsError, fn -> Collaborations.get_invite_offer!(invite_offer.id) end
    end

    test "change_invite_offer/1 returns a invite_offer changeset" do
      invite_offer = invite_offer_fixture()
      assert %Ecto.Changeset{} = Collaborations.change_invite_offer(invite_offer)
    end
  end
end
