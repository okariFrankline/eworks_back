defmodule Mpesa.C2B do
  @moduledoc """
    Defines the method responsible for the performing a c2b transaction for mpesa
  """
  alias Mpesa.Oauth

  @doc """
    Registers the url for mpesa c2b transaction
  """
  def register_c2b_url(response_type = "Completed") do
    case Oauth.access_token() do
      {:ok, token} ->
        # body
        body = %{
          "ShortCode" => Application.get_env(:c2b, :short_code),
          "ResponseType" => response_type,
          "ConfirmationURL" => Application.get_env(:c2b, :confirmation_url),
          "ValidationURL" => Application.get_env(:c2b, :validation_url)
        }
        # ensode the data
        |> Jason.encode!()

        # post the data
        HTTPoison.post("#{Application.get_env(:mpesa, :baseUrl)}/mpesa/c2b/v1/registerurl", body, headers(token))

      # error
      {:error, _message} = result -> result
    end # end of case
  end # end of register c2b url

  @doc """
    Simulates a c2b transaction
  """
  def c2b_simulate(msisdn, amount, bill_ref_number, command_id \\ "CustomerPayBillOnline") do
    case Oauth.access_token() do
      {:ok, token} ->
        # body
        body = %{
          "ShortCode" => Application.get_env(:c2b, :short_code),
          "CommandId" => command_id,
          "BillRefNumber" => bill_ref_number,
          "Amount" => amount,
          "Msisdn" => msisdn
        }
        # ensode the data
        |> Jason.encode!()
        # post the data
        HTTPoison.post("#{Application.get_env(:mpesa, :baseUrl)}/mpesa/c2b/v1/simulate", body, headers(token))

      # error
      {:error, _message} = result -> result
    end # end of case
  end # end of c2b simulate

  # function for getting the headers
  defp headers(token) do
    [
      "Authorization": "Bearer #{token}",
      "content-type": "application/json"
    ]
  end # end of function for getting the headers



end # end of the mpesa c2b
