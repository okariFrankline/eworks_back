defmodule EworksWeb.ErrorView do
  use EworksWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  # function for rendering the not_owner function
  def render("not_owner.json", _message) do
    %{errors: %{
      details: "Failed. You cannot edit another user's profile"
    }}
  end # end of the not owner

  # function fore rendering the same email json
  def render("same_email.json", %{message: message}) do
    %{errors: %{
      details: message
    }}
  end # end of the same_email.json

  # function for handling the is client error
  def render("is_client.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Offer not placed because you are a client."
      }
    }
  end

  # function for rendering already assigned
  def render("already_assigned.json", _) do
    %{
      errors: %{
        details: "Failed. Order already assigned"
      }
    }
  end

  # function for rendering cancelled offer error
  def render("cancelled_offer.json", _) do
    %{
      errors: %{
        details: "Failed. Offer cancelled by owner."
      }
    }
  end

  # unauthenticated.json
  def render("unauthenticated.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Login to continue."
      }
    }
  end

  # not active json
  def render("not_active.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Account not active. Please verify to continue."
      }
    }
  end

  # invalid activation key
  def render("invalid_activation_key.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Invalid activation key."
      }
    }
  end

  # invalid activation key
  def render("invalid_verification_code.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Invalid Order Verification Code."
      }
    }
  end

  # upgrade-expired.json
  def render("upgrade_expired.json", %{expiry_date: date} do
    %{
      errors: %{
        details: "Failed. Your one time upgrade expired on #{DateTime.to_iso8601(date)}"
      }
    }
  end # end of upgrade_expired.json


end # end of the module
