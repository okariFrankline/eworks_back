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
  def render("upgrade_expired.json", %{expiry_date: date}) do
    %{
      errors: %{
        details: "Failed. Your one time upgrade expired on #{DateTime.to_iso8601(date)}"
      }
    }
  end # end of upgrade_expired.json

  # user_suspended.json
  def render("user_suspended.json", %{user_name: name}) do
    %{
      errors: %{
        details: "Failed. The offer owner's account: #{name} has been suspended."
      }
    }
  end # end of user_suspended.json

  # prof not found
  def render("prof_not_found.json", _assigns) do
    %{
      errors: %{
        details: "Failed. Offer owner does not exist."
      }
    }
  end

  # max_offers
  def render("max_offers.json", _) do
    %{
      errors: %{
        details: "Faled. Maximum number of offers to accept reached."
      }
    }
  end

  # worker_not found
  def render("work_not_found.json", _) do
    %{
      errors: %{
        details: "Failed. Independent Contractor Not Found."
      }
    }
  end # end of worker not found

  # ordernot found
  def render("order_not_found.json", _) do
    %{
      errors: %{
        details: "Failed. Order Not Found."
      }
    }
  end # end of worker not found

  # failed.json
  def render("save_failed.json", _) do
    %{
      errors: %{
        details: "Failed. Contractor could not be saved."
      }
    }
  end # end of worker not found

end # end of the module
