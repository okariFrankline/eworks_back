defmodule Mpesa.PublicKey do
  @moduledoc """
    This module will work with public key reading and extraction
  """
  require Mpesa.PublicKey.Record

  alias Mpesa.PublicKey.Record

  @doc """
  Extract public key from the certicate file

  iex > Mpesa.PublicKey.extract_public_from(path)

  ```
  {:RSAPublicKey, 2129828641 ..}
  ```
  """
  @spec extract_public_from(String.t()) :: {atom(), integer()}
  def extract_public_from(certfile) do
    # get the certificate text
    cert_text =
      File.read!(certfile)
      # trim the file
      |> String.trim()

    [pem_entry] = :public_key.pem_decode(cert_text)

    plk_der =
      :public_key.pem_entry_decode(pem_entry)
      |> Record."Certificate"(:tbsCertificate)
      |> Record."TBSCertificate"(:subjectPublicKeyInfo)
      |> Record."SubjectPublicKeyInfo"(:subjectPublicKey)

    :public_key.der_decode(:RSAPublicKey, plk_der)
  end

  @doc """
  Take a public certificate encyypt it and then encode the cypher string to base64

  iex > Mpesa.PublicKey(public_key, "test")

  ```
  fdffdf ...
  ```
  """
  @spec generate_base64_cypherstring(term(), String.t()) :: String.t()
  def generate_base64_cypherstring(public_key, plain_text) do
    plain_text
    |> :public_key.encrypt_public(public_key, [{:rsa_pad, :rsa_pkcsa1_padding}])
        # encode result
    |> :base64.encode()
  end

end # end of the module definiton
