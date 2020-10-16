defmodule Eworks.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias Eworks.{Repo, Accounts}

  alias Eworks.Orders.Order

  # function for creating a new Order user from Accounts user
  def order_user_from_account_user(%Accounts.User{id: id} = _user), do: %__MODULE__.User{id: id}

  # function for returning an account user from the order user
  def account_user_from_order_user(%__MODULE__.User{id: id}  = _user), do: %Accounts.User{id: id}

  # function for returning an account user from the order assignee
  def account_user_from_order_assignee(%__MODULE__.Order.Assignee{id: id}  = _user), do: %Accounts.User{id: id}

  # set up the dataloader
  def data() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end # end of daaloader

  def query(queryable, _), do: queryable

  # dataloader for the

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def list_orders do
    Repo.all(Order)
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates a order.

  ## Examples

      iex> create_order(%{field: value})
      {:ok, %Order{}}

      iex> create_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(%Order{} = order, attrs \\ %{}) do
    order
    |> Order.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's attachments.

  ## Examples

      iex> update_order_attachments(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_attachments(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_attachments(%Order{} = order, attrs) do
    order
    |> Order.attachments_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's payment information.

  ## Examples

      iex> update_order_payment(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_payment(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_payment(%Order{} = order, attrs) do
    order
    |> Order.payment_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's type and duration.

  ## Examples

      iex> update_order_duration(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_duration(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_duration(%Order{} = order, attrs) do
    order
    |> Order.duration_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's type and the required numbr of contractors.

  ## Examples

      iex> update_order_type_and_contractors(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_type_and_contractors(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_type_and_contractors(%Order{} = order, attrs) do
    order
    |> Order.type_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's type and the required numbr of contractors.

  ## Examples

      iex> update_order_type_and_contractors(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_type_and_contractors(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_category(%Order{} = order, attrs) do
    order
    |> Order.category_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a order's desription.

  ## Examples

      iex> update_order_description(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order_description(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_description(%Order{} = order, attrs) do
    order
    |> Order.description_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  alias Eworks.Orders.OrderOffer

  @doc """
  Returns the list of order_offers.

  ## Examples

      iex> list_order_offers()
      [%OrderOffer{}, ...]

  """
  def list_order_offers do
    Repo.all(OrderOffer)
  end

  @doc """
  Gets a single order_offer.

  Raises `Ecto.NoResultsError` if the Order offer does not exist.

  ## Examples

      iex> get_order_offer!(123)
      %OrderOffer{}

      iex> get_order_offer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order_offer!(id), do: Repo.get!(OrderOffer, id)

  @doc """
  Updates a order_offer.

  ## Examples

      iex> update_order_offer(order_offer, %{field: new_value})
      {:ok, %OrderOffer{}}

      iex> update_order_offer(order_offer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order_offer(%OrderOffer{} = order_offer, attrs) do
    order_offer
    |> OrderOffer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a order_offer.

  ## Examples

      iex> delete_order_offer(order_offer)
      {:ok, %OrderOffer{}}

      iex> delete_order_offer(order_offer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order_offer(%OrderOffer{} = order_offer) do
    Repo.delete(order_offer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order_offer changes.

  ## Examples

      iex> change_order_offer(order_offer)
      %Ecto.Changeset{data: %OrderOffer{}}

  """
  def change_order_offer(%OrderOffer{} = order_offer, attrs \\ %{}) do
    OrderOffer.changeset(order_offer, attrs)
  end
end
