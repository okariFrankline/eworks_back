defmodule Mpesa.Oauth do
  @moduledoc """
    Authenticates the app and returns the
  """
  #alias Mpesa.PublicKey
  require Mpesa.PublicKey.Record
  alias Mpesa.PublicKey.Record
  alias Mpesa.Utils

  @doc """
    Returns the access token from mpesa api
  """
  def access_token() do
    # get the base url
    base_url = Utils.base_url()
    # get the consumer key
    auth = "#{Utils.consumer_key()}:#{Utils.consumer_secret()}" |> Base.encode64()
    # headers
    headers = ["Authorization": "Basic #{auth}", "content-type": "application/json"]
    # start the httpoison
    HTTPoison.start()
    # get the access token
    case HTTPoison.get("#{base_url}/oauth/v1/generate?grant_type=client_credentials", headers) do
      {:ok, response} ->
        # get the response
        token = response.body |> Jason.decode!() |> Map.get("access_token")
        # return the token
        {:ok, token}

      {:error, _message} = result -> result
    end # end of gettign the response
  end # end of the auth

  @doc """
    Generates the security credentials for form the certificate
  """
  @spec b2c_security_credentials :: String.t()
  def b2c_security_credentials do
    # get the cert file
    cert_file_path = Application.get_env(:mpesa, :cert_file_path)
    # get the passkey
    pass_key = Application.get_env(:b2c, :credentials)

    case File.read(cert_file_path) do
      # file read successfully
      {:ok, data} ->
        cert_text = data |> String.trim()

        [pem_entry] = :public_key.pem_decode(cert_text)
        cert_decoded = :public_key.pem_entry_decode(pem_entry)

        plk_der =
          cert_decoded
          |> Record."Certificate"(:tbsCertificate)
          |> Record."TBSCertificate"(:subjectPublicKeyInfo)
          |> Record."SubjectPublicKeyInfo"(:subjectPublicKey)

        plk = :public_key.der_decode(:RSAPublicKey, plk_der)

        # encrypt the data
        pass_key
        # encrypt the data
        |> :public_key.encrypt_public(plk, [{:rsa_pad, :rsa_pkcsa1_padding}])
        # encode result
        |> :base64.encode()

      # file could not be read
      {:error, reason} ->
        # formated error
        fmt_err = :file.format_error(reason) |> to_string() |> String.capitalize()
        # return error
        {:error, fmt_err}
    end # end of reading the file
  end # end of mpesa.public key

end # end of the module
