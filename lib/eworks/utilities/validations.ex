defmodule Eworks.Utils.Validations do
  @moduledoc """
    Provides utility functions for validating an email
  """

  @countries_codes %{
    "kenya" => "KE",
    "uganda" => "UG",
    "tanzania" => "TZ",
    "rwanda" => "RW",
    "south sudan" => "SS"
  }

  # function for validating email address
  def is_valid_email?(email) do
    case Regex.run(~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i, email) do
      # the email is valid
      nil ->
        :error
      # the email is invalid
      _ ->
        :ok
    end
  end # end of is valid_email

  @doc """
  Validates whether a given phone number is valid for the country provided and returns the international number

    iex> is_valid_phone?("0723007945", "Kenya")
      {:ok, +254723007945}

    iex> is_valid_phone?("0472840844", "Kenya")
      :error
  """
  def is_valid_phone?(phone, country) do
    # get the country from the list of country codes
    country_code = @country_codes |> Map.fetch!(country |> String.downcase)
    # craete the phone number using ExPhoneNUmber
    {:ok, phone_number} = ExPhoneNumber.parse(phone, country_code)
    # check if the phone number is valid
    if ExPhoneNumber.is_valid_number?(phone_number) do
      # internationalize the number and put it in the changese
      phone_number = ExPhoneNumber.format(phone_number, :international)
      # return an okay tuple with the international number
      {:ok, phone_number}
    else # the phone number is invalid
      # add an error message
      :error
    end # end of checking the validity of the phone number
  end # end of is_valid_phone?/2

end # end of the defmodule for validating the email address
