defmodule MemzWeb.EventView do
  use MemzWeb, :view
  alias MemzWeb.EventView

  def render("index.json", %{events: events}) do
    %{data: render_many(events, EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{event: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      name: event.name,
      owner: event.owner,
      end_date: event.end_date}
  end
end
