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
end
