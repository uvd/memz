defmodule MemzWeb.ImageView do
  use MemzWeb, :view

  alias MemzWeb.ImageView
  alias Memz.Events.Uploader
  alias Memz.Repo

  def render("index.json", %{images: images}) do
    %{data: render_many(images, ImageView, "image.json")}
  end

  def render("show.json", %{image: image}) do
    %{data: render_one(image, ImageView, "image.json")}
  end

  def render("image.json", %{image: image}) do
    image = Repo.preload(image, :user)

    public_url = Uploader.url({image.file, image})

    %{path: public_url, owner: image.user.name, date: image.inserted_at}
  end
end
