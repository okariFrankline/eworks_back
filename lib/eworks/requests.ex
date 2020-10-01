defmodule Eworks.Requests do
  @moduledoc """
  The Requests context.
  """

  import Ecto.Query, warn: false
  alias Eworks.Repo

  alias Eworks.Requests.DirectHire

  @doc """
  Returns the list of direct_hires.

  ## Examples

      iex> list_direct_hires()
      [%DirectHire{}, ...]

  """
  def list_direct_hires do
    Repo.all(DirectHire)
  end

  @doc """
  Gets a single direct_hire.

  Raises `Ecto.NoResultsError` if the Direct hire does not exist.

  ## Examples

      iex> get_direct_hire!(123)
      %DirectHire{}

      iex> get_direct_hire!(456)
      ** (Ecto.NoResultsError)

  """
  def get_direct_hire!(id), do: Repo.get!(DirectHire, id)

  @doc """
  Creates a direct_hire.

  ## Examples

      iex> create_direct_hire(%{field: value})
      {:ok, %DirectHire{}}

      iex> create_direct_hire(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_direct_hire(attrs \\ %{}) do
    %DirectHire{}
    |> DirectHire.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a direct_hire.

  ## Examples

      iex> update_direct_hire(direct_hire, %{field: new_value})
      {:ok, %DirectHire{}}

      iex> update_direct_hire(direct_hire, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_direct_hire(%DirectHire{} = direct_hire, attrs) do
    direct_hire
    |> DirectHire.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a direct_hire.

  ## Examples

      iex> delete_direct_hire(direct_hire)
      {:ok, %DirectHire{}}

      iex> delete_direct_hire(direct_hire)
      {:error, %Ecto.Changeset{}}

  """
  def delete_direct_hire(%DirectHire{} = direct_hire) do
    Repo.delete(direct_hire)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking direct_hire changes.

  ## Examples

      iex> change_direct_hire(direct_hire)
      %Ecto.Changeset{data: %DirectHire{}}

  """
  def change_direct_hire(%DirectHire{} = direct_hire, attrs \\ %{}) do
    DirectHire.changeset(direct_hire, attrs)
  end
end
