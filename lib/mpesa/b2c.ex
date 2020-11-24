defmodule Mpesa.B2C do
  @moduledoc """
    Defines the method responsible for the performing a b2c transaction for mpesa
  """
  alias Mpesa.Oauth

  def initiate_payment(amount, receiver_party, command_id \\ "Business Payment", remarks, occassion) do
    case Mpesa.Oauth.access_token() do
      {:ok, token} ->
        # headers
        headers = ["Authorization": "Bearer #{token}", "Content-Type": "application/json; charset=utf-8"]
        # body
        body = %{
          "InitiatorName" => Application.get_env(:b2c, :initiator_name),
          "SecurityCredentials" => Oauth.b2c_security_credentials(),
          "CommandID" => command_id,
          "Amount" => amount,
          "PartyA" => Application.get_env(:b2c, :sender_short_code),
          "PartyB" => receiver_party,
          "Remarks" => remarks,
          "QueueTimeURL" => Application.get_env(:b2c, :queue_time_url),
          "ResultURL" => Application.get_env(:b2c, :result_url),
          "Occassion" => occassion
        }
        # encode the body
        |> Jason.encode!()

        # post the data
        HTTPoison.post(Application.get_env(:mpesa, :base_url) <> "/mpesa/b2c/v1/paymentrequest", body, headers)

      {:error, _message} = result -> result

    end
  end # end of the initiate payment
end # end of the B2C module
