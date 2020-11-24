defmodule Mpesa.LipaNaMpesa do
  @moduledoc """
    Defines the function for transacting a lipa na mpesa using the stk
  """
  alias Mpesa.{Oauth, Utils}


  @callback_url "https://requestbin.net/r/ru8rr9ru"

  @doc """
    Initiates a lipa na mpesa stk request
  """
  def initiate_payment(%{creditor: phone, payable_amount: amount , account_ref: ref, transaction_desc: desc}) do
    # get the access token
    case Oauth.access_token() do
      {:ok, token} ->
        IO.puts(token)
        # get the current timestamp
        {:ok, timestamp} = Timex.now() |> Timex.format("%Y%m%d%H%M%S", :strftime)

        # generate the password
        password = Base.encode64(short_code() <> pass_key() <> timestamp)
        # headers
        headers = ["Authorization": "Bearer #{token}", "content-type": "application/json; charset=utf-8"]
        # body of the request
        body = %{
          "BusinessShortCode" => short_code(),
          "Password" => password,
          "Timestamp" => timestamp,
          "TransactionType" => "CustomerPayBillOnline",
          "Amount" => amount,
          "PartyA" => phone,
          "PartyB" =>  short_code(),
          "PhoneNumber" => phone,
          "CallbackUrl" => @callback_url,
          "AccountReference" => ref,
          "TransacationDesc" => desc
        }
        # ensode the body
        |> Jason.encode!()

        IO.inspect(body)

        # post the data to safaricom
        HTTPoison.post(Utils.base_url() <> "/mpesa/stkpush/v1/processrequest", body, headers)

      {:error, _message} = result -> result
    end # end of getting the acces token
  end # end of initiate payment

  @doc """
    API function for checking the status of a Lipa Na M-Pesa Online Payment
  """
  def status_query(checkout_request_id) do
    case Oauth.access_token() do
      # success
      {:ok, token} ->
        # get the current timestamp
        {:ok, timestamp} = Timex.now() |> Timex.format("%Y%m%d%H%M%S", :strftime)
        # generate the password
        password = Base.encode64(short_code() <> pass_key() <> timestamp)
        # headers
        headers = ["Authorization": "Bearer #{token}", "content-type": "application/json; charset=utf-8"]

        # body
        body = %{
          "BusinessShortCode" => short_code(),
          "Password" => password,
          "Timestamp" => timestamp,
          "CheckoutRequestID" => checkout_request_id
        }
        # encode the data
        |> Jason.encode!()

        # post the request to mpesa
        HTTPoison.post(Utils.base_url() <> "/mpesa/stkpushquery/v1/query", body, headers)

      # error
      {:error, _message} = result -> result
    end # end of getting the access token
  end # end of status_query

  # function for getting the short_code
  defp short_code do
    if Mix.env() == :dev, do: "174379", else: {System, "LNMP_SHORT_CODE"}
  end
  # get the pass key
  defp pass_key do
    if Mix.env() == :dev, do: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919", else: {System, "LNMP_PASS_KEY"}
  end

end # end of LipaNaMpesa module
