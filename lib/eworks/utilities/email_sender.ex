defmodule Eworks.Utils.NewEmail do
  @moduledoc """
  Used to generate an email
  """
  import Bamboo.Email
  alias Eworks.Accounts.User
  alias Eworks.Orders.Order

  # function for generating an email after signing in a user
  def new_activation_key_email(%User{auth_email: email} = _user, subject, message) do
    # create the email to send to the user
    base_mail()
    # add where the email is to be sent to
    |> to(email)
    # subject
    |> subject(subject)
    # text body
    |> text_body(message)
  end

  # function for sending the order verification code
  def new_order_verification_code_email(%User{auth_email: email} = _user, %Order{verification_code: code, specialty: specialty}) do
    base_mail()
    # put the sender of the email
    |> to(email)
    # subject of the email
    |> subject("New Order Verification Code. **ORDER::#{specialty}**")
    # subject of the email
    |> text_body("Thank you for creating a new order with us. Here is your order verification code: \n #{code}")
  end # end of the new order verification code email

  # function for sending an invite accepting offer
  def new_email_notification(%User{auth_email: email} = _user, subject, message) do
    base_mail()
    # put the sender of the email
    |> to(email)
    # subject of the email
    |> subject(subject)
    # subject of the email
    |> text_body(message)
  end # end of new_invite_email_notification

  # base email
  def base_mail do
    new_email()
    |> from("frankline@otbafrica.com")
  end # end of base email
end # end of the module
