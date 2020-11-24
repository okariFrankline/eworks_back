defmodule Eworks.PaymentAPI do
  @moduledoc """
    Provides api function for payment
  """
  alias Eworks.Utils.Validations
  alias Mpesa.LipaNaMpesa, as: Lipa
  alias Eworks.Accounts.User

  @constant_upgrade_fee 50

  @doc """
    Upgrade payment
  """
  def upgrade_payment(%User{country: country} = _user, phone, duration) do
    # get the payable amount
    payable_amount = duration * @constant_upgrade_fee
    # get the internationalized phone number'
    case Validations.is_valid_number?(phone, country) do
      # is a valid number
      {:ok, _phone} ->
        # initiate the payment
        :ok

      :error -> :error
    end # end of checking of a number is a valid number

  end # end of upgrade payment


  # private function for getting the international number
  def international_number(%User{country: country} = _user, phone) do
    # check if the number is valid
    case Validations.is_valid_number?(phone, country) do
      # is a valid number
      {:ok, number} -> number

      :error -> :error
    end # end of checking of a number is a valid number
  end # end of getting the international number

end
