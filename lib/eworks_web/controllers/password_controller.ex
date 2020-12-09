defmodule EworksWeb.Passwords.PasswordController do
  @moduledoc """
    Defines functions for handling password changes
  """
  use EworksWeb, :controller
  alias Eworks.{Repo, Accounts}
  alias Eworks.Utils.{NewEmail, Mailer}

  @doc """
    confirm email
    Recieves an auth email and confirms whether the email exists in the system
    If the email exists, the user account's activation code is set and an email is sent to the user.
  """
  def confirm_email(conn, %{"auth_email" => email}) do
    # get the user with the given account
    case Repo.get_by(Accounts.User, auth_email: email) do
      # the user exists
      %Accounts.User{} = user ->
        # genreate a new six digit figure
        code = Enum.random(100_000..999_999)
        # update the user
        user
        |> Ecto.Changeset.change(%{
          activation_key: code
        })
        |> Repo.update!()

        # generate a new email address and send if to the user
        NewEmail.new_activation_key_email(
          user,
          "Password Reset Verification Code",
          "Here is your password reset activation code: #{code}."
        )
        |> Mailer.deliver_later()

        # return a response
        conn
        |> put_status(:ok)
        |> put_view(EworksWeb.Users.UserView)
        |> render("success.json", message: "Your 6 digit password verification code has being sent to #{email}.")
      # the user does not exist
      nil ->
        render_user_not_found(conn, email)
    end
  end # end of confirm email

  @doc """
    Verify code
    Verifies that the code provides during the password reset period
  """
  def verify_code(conn, %{"auth_email" => email, "verification_code" => code}) do
    # get the user with the given id
    case Repo.get_by(Accounts.User, auth_email: email) do
      # the user exists
      %Accounts.User{activation_key: activation_code} = user ->
        IO.inspect(activation_code)
        if activation_code == code |> String.to_integer() do
          # set the activation code to nil
          # return a response
          user
          |> Ecto.Changeset.change(%{
            activation_key: nil
          })
          |> Repo.update!()

          # send a response
          conn
          |> send_resp(:ok, "")
        else
          # return an error message
          conn
          |> put_status(:forbidden)
          |> put_view(EworksWeb.ErrorView)
          |> render("failed.json", message: "Failed. The verification code entered is incorrect. Please try again.")
        end

      nil ->
        render_user_not_found(conn, email)
    end
  end # end of verify code

  @doc """
    New password
    Sets a new pasword to the account of the user identified with the given email address
  """
  def set_new_password(conn, %{"auth_email" => email, "password" => new_pass}) do
    # get teh user with the given ema
    case Repo.get_by(Accounts.User, auth_email: email) do
      # user was found
      %Accounts.User{} = user ->
        # update the user's password
        user
        |> Accounts.User.reset_password_changeset(%{password: new_pass})
        |> Repo.update!()

        # return the result
        conn
        |> put_status(:ok)
        |> put_view(EworksWeb.Users.UserView)
        |> render("success.json", message: "Success. Your account password has being successfully reset. Please login to access your account.")

      nil ->
        render_user_not_found(conn, email)
    end
  end # end of set new password

  @doc """
    Resend verification code
    Generates a new verification code and then resends the verification code to the user identified by the given email address

  """
  def resend_verification_code(conn, %{"auth_email" => email}) do
    # get the user
    case Repo.get_by(Accounts.User, auth_email: email) do
      # user found
      %Accounts.User{} = user ->
        code = Enum.random(100_000..999_999)

        # update ther user
        user
        |> Ecto.Changeset.change(%{
          activation_key: code
        })
        |> Repo.update!()

        # send the code via the email
        NewEmail.new_activation_key_email(
          user,
          "New Password Reset Verification Key",
          "Here is your new account password verification code: #{code}."
        )
        |> Mailer.deliver_later()

        # return teh result
        conn
        |> put_status(:ok)
        |> put_view(EworksWeb.Users.UserView)
        |> render("success.json", message: "Success. Your new password reset verification code has been sent to #{email}")

      # user not found
      nil ->
        render_user_not_found(conn, email)
    end
  end # end of resend verification code

  # renders user not found result
  @spec render_user_not_found(Plug.Conn.t(), String.t()) :: Plug.Conn.t()
  defp render_user_not_found(conn, email) do
    # return a response
    conn
    # put a status
    |> put_status(:not_found)
    # put error view
    |> put_view(EworksWeb.ErrorView)
    # render failed
    |> render("failed.json", message: "Account with email address: #{email} does not exist.")
  end # end of render_user_not_found
end # end of password controller
