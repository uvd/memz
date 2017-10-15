defmodule Memz.Events.Uploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  alias Memz.Repo

  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  def acl(:thumb, _), do: :public_read

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(@extension_whitelist, file_extension)
  end

  def transform(:thumb, _) do
    {:convert, "-geometry 800x -format png", :png}
  end

  # To retain the original filename, but prefix the version and user id:
  def filename(version, {file, scope}) do
    file_name = Path.basename(file.file_name, Path.extname(file.file_name))
    "#{version}_#{file_name}"
  end

  # To make the destination file the same as the version:
  def filename(version, _), do: version

  def storage_dir(version, {file, image}) do
    image = Repo.preload(image, :event)
    Integer.to_string(image.event.id)
  end

  def default_url(:thumb) do
    "https://placehold.it/100x100"
  end

  def s3_object_headers(version, {file, scope}) do
    # for "image.png", would produce: "image/png"
    [content_type: Plug.MIME.path(file.file_name)]
  end
end
