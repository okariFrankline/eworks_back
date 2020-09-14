defmodule Eworks.Utils.NewEmail do
  @moduledoc """
  Used to generate an email
  """
  import Bamboo.Email
  alias Eworks.Accounts.User

  # function for generating an email after signing in a user
  def new_activation_email(%User{activation_key: key, auth_email: email } = _user) do
    # create the email to send to the user
    base_mail()
    # add where the email is to be sent to
    |> to(email)
    # subject
    |> subject("Eworks Registration Confirmation")
    # text body
    |> text_body("Thank you for registering for an account. Here is your account activation code: \n #{key}")
  end

  # base email
  def base_mail do
    new_email()
    |> from("frankline@otbafrica.com")
  end # end of base email
end # end of the module
