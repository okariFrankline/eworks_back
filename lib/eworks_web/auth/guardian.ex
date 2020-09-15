defmodule EworksWeb.Authentication.Guardian do
  @moduledoc """
    Defines a guardian models
  """
  use Guardian, otp_app: :eworks
  alias Eworks.Accounts
  alias Eworks.Accounts.User

  # define the subject_for_token
  # @spec subject_for_token(User, any) :: {:error, :unauthorized} | {:ok, binary}
  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end # end of the subject for token
  def subject_for_token(_, _), do: {:error, :unauthorized}

  # resorce from claims
  # @spec resource_from_claims(map()) ::
  #         {:error, :unauthorized} | {:error, :unauthorized} | {:ok, User}
  def resource_from_claims(%{"sub" => id} = _claims) do
    # get the user with the id
    case Accounts.get_user(id) do
      {:ok, _user} = resource ->
        # return the user
        resource

      _ ->
        # return the error
        {:error, :unauthorized}
     end # end of getting the account with the id
  end # end of resource_from_claims
  def resource_from_claims(_), do: {:error, :unauthorized}

  # function for
end # end of the module
