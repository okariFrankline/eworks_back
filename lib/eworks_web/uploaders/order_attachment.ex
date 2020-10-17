defmodule Eworks.Uploaders.OrderAttachment do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition
  # alias the orders
  alias Eworks.Orders

  @versions [:original]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.zip .docx) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/orders"
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

  @doc """
    Function for uploading the documents to s3 and storing them to the db
  """
  def upload_attachments(%Orders.Order{} = order, [attachment | _rest] = attachments) do
    # check the number of attachments and the attachment type
    if Enum.count(attachments) == 1 and is_docx_document?(attachment)do
      # upload teh document as is
       Orders.update_order_attachments(order, %{attachments: attachment})
    else
      # zip the document and upload to s3
      zip_attachments(order, attachments)
    end
  end # end of uploading attachments

  # function for checking whether a document is docx
  defp is_docx_document?(%Plug.Upload{filename: filename}) do
    if Path.extname(filename) in [".docx, .odt"], do: true, else: false
  end # end of id_docx_document?/1

  # function for zipping attachments
  defp zip_attachments(%Orders.Order{} = order, attachments) do
    # get the files
    files = attachments |> Enum.map(fn attachment -> String.to_charlist(attachment.path) end)
    # create a zip fiel with the documents
    {:ok, zip_filename} = :zip.create("#{Ecto.UUID.generate()}.zip", files)
    # create a new upload struct with the file
    zip_upload = %Plug.Upload{filename: zip_filename, path: Path.absname(zip_filename), content_type: "application/zip"}

    # update the order
    with {:ok, _order} = result <- Orders.update_order_attachments(order, %{attachments: zip_upload}) do
      # delete the temporary zip file
      Task.start(fn -> File.rm!(Path.absname(zip_filename)) end)
      # return the result
      result
    end # end of order upload
  end # end of zip_attachments/1

end # end of the module
