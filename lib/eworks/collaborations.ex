defmodule Eworks.Collaborations do
  @moduledoc """
  The Collaborations context.
  """

  import Ecto.Query, warn: false
  alias Eworks.{Repo}

  alias Eworks.Collaborations.Invite

  @doc """
  Returns the list of invites.

  ## Examples

      iex> list_invites()
      [%Invite{}, ...]

  """
  def list_invites do
    Repo.all(Invite)
  end

  @doc """
  Gets a single invite.

  Raises `Ecto.NoResultsError` if the Invite does not exist.

  ## Examples

      iex> get_invite!(123)
      %Invite{}

      iex> get_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invite!(id), do: Repo.get!(Invite, id)

  @doc """
  Creates a invite.

  ## Examples

      iex> create_invite(%{field: value})
      {:ok, %Invite{}}

      iex> create_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite(%Invite{} = invite, attrs \\ %{}) do
    IO.inspect(invite)
    invite
    |> Invite.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invite.

  ## Examples

      iex> update_invite(invite, %{field: new_value})
      {:ok, %Invite{}}

      iex> update_invite(invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite_payment(%Invite{} = invite, attrs) do
    invite
    |> Invite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invite.

  ## Examples

      iex> delete_invite(invite)
      {:ok, %Invite{}}

      iex> delete_invite(invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite(%Invite{} = invite) do
    Repo.delete(invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite changes.

  ## Examples

      iex> change_invite(invite)
      %Ecto.Changeset{data: %Invite{}}

  """
  def change_invite(%Invite{} = invite, attrs \\ %{}) do
    Invite.changeset(invite, attrs)
  end

  alias Eworks.Collaborations.InviteOffer

  @doc """
  Returns the list of invite_offers.

  ## Examples

      iex> list_invite_offers()
      [%InviteOffer{}, ...]

  """
  def list_invite_offers do
    Repo.all(InviteOffer)
  end

  @doc """
  Gets a single invite_offer.

  Raises `Ecto.NoResultsError` if the Invite offer does not exist.

  ## Examples

      iex> get_invite_offer!(123)
      %InviteOffer{}

      iex> get_invite_offer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invite_offer!(id), do: Repo.get!(InviteOffer, id)

  @doc """
  Creates a invite_offer.

  ## Examples

      iex> create_invite_offer(%{field: value})
      {:ok, %InviteOffer{}}

      iex> create_invite_offer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invite_offer(attrs \\ %{}) do
    %InviteOffer{}
    |> InviteOffer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a invite_offer.

  ## Examples

      iex> update_invite_offer(invite_offer, %{field: new_value})
      {:ok, %InviteOffer{}}

      iex> update_invite_offer(invite_offer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invite_offer(%InviteOffer{} = invite_offer, attrs) do
    invite_offer
    |> InviteOffer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a invite_offer.

  ## Examples

      iex> delete_invite_offer(invite_offer)
      {:ok, %InviteOffer{}}

      iex> delete_invite_offer(invite_offer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invite_offer(%InviteOffer{} = invite_offer) do
    Repo.delete(invite_offer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invite_offer changes.

  ## Examples

      iex> change_invite_offer(invite_offer)
      %Ecto.Changeset{data: %InviteOffer{}}

  """
  def change_invite_offer(%InviteOffer{} = invite_offer, attrs \\ %{}) do
    InviteOffer.changeset(invite_offer, attrs)
  end
end
