defmodule Mpesa.Utils do
  @moduledoc false

  @doc """
    returns the base url depending on hte env
  """
  def base_url do
    if Mix.env() == :dev, do: "https://sandbox.safaricom.co.ke", else: ""
  end

  @spec consumer_key :: <<_::256>> | {System, <<_::144>>}
  @doc """
    Returns the  consumer key
  """
  def consumer_key do
    if Mix.env() == :dev, do: "Jd43MFwP1AKVROrs8Pg6iNBXZhDJYNYt", else: {System, "MPESA_CONSUMER_KEY"}
  end

  @spec consumer_secret :: <<_::128>> | {System, <<_::168>>}
  @doc """
    Returns the consumer secret
  """
  def consumer_secret do
    if Mix.env() == :dev, do: "fQSE0fg4g5UZfHfO", else: {System, "MPESA_CONSUMER_SECRET"}
  end

end # end of utils
