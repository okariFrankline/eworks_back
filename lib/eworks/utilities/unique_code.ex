defmodule Eworks.Utils.UniqueCode do
  @moduledoc """
    Responsible for the generation of a random unique code
  """

  @doc """
    Generates a random six number between 100000 and 999999
  """
  def generate do
    Enum.random(100_000..999_999)
  end # end of generate function
  
end # end of the module
