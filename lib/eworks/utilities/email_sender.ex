defmodule Eworks.Utils.NewEmail do
  @moduledoc """
  Used to generate an email
  """
  import Bamboo.Email
  alias Eworks.Accounts.User
  alias Eworks.Orders.Order

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

  # function for sending the order verification code
  def new_order_verification_code_email(%User{auth_email: email} = _user, %Order{verification_code: code, specialty: specialty}) do
    base_email()
    # put the sender of the email
    |> to(email)
    # subject of the email
    |> subject("New Order Verification Code: #{specialty}")
    # subject of the email
    |> text_body("Thank you for creating a new order with us. Here is your order verification code: \n #{code}")
  end # end of the new order verification code email

  # base email
  def base_mail do
    new_email()
    |> from("frankline@otbafrica.com")
  end # end of base email
end # end of the module
