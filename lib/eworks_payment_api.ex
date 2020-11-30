defmodule Eworks.Payment.API do
  @moduledoc """
    Provides payment api for the entire application
  """

  @doc """
    Initialize lipa na mpesa
  """
  def lipa_na_mpesa() do
    :ok
  end

  @doc """
    Initialize sending money to a client
  """
  def pay_contractor(%{phone: _phone, amount: _amount}) do
    :ok
  end
end
