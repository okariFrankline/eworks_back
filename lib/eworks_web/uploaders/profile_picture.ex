defmodule Eworks.Uploaders.ProfilePicture do
  @moduledoc """
  Defines a module that will be used to handle uploads of profile photos
  """
  use Waffle.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Waffle.Ecto.Definition

  # To add a thumbnail version:
  @versions [:original, :thumb]

  @acl :public_read

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end
  def acl(:thumb, _), do: :public_read


  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  # file name should be in the form of user.id_version
  # example hhfjh-KhU8_thumb.png
  # def filename(version, {file, _scope}) do
  #   IO.inspect(file)
  #   # generate a unique name
  #   uuid = UUID.uuid4()
  #   # get the current timestamp
  #   # current_date = DateTime.utc_now() |> DateTime.to_iso8601() |> String.replace(":", "_")
  #   # return the file name
  #   "#{file.file_name}_#{uuid}_#{version}.#{Path.extname(fil)}"
  # end

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/avatars/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  def s3_object_headers(_version, {file, _scope}) do
    [content_type: MIME.from_path(file.file_name)]
  end

end # end of the module definition
