defmodule Eworks.Accounts.Utils do
  @moduledoc """
    Defines utility functions for the Accounts context
  """

  # function for getting the username from the email
  @doc """
    Get username takes an email address and returns the name before the domain of the email address
    ## Examples

      iex> get_username(frank@gmail.com)
        frank
  """
  def get_username(email) when is_binary(email), do: Regex.run(~r/(\w+)@([\w.]+)/, email)

  @doc """
    Validates the current password
  """
  def validate_current_password(hash, password), do: Argon2.verify_pass(password, hash)

end # end of module
