defmodule EworksWeb.Authentication.Guardian.AuthPipeline do
  @moduledoc """
    Defines a pipeline for ensureing the user is authenticated
  """
  use Guardian.Plug.Pipeline, otp_app: :eworks, module: EworksWeb.Authentication.Guardian,
    error_handler: EworksWeb.Authentication.Guardian.ErrorHandler

  # plug for verifying the header
  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  # plug for ensuring the user is authenticated
  plug Guardian.Plug.EnsureAuthenticated


end # end of the module.
