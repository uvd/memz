defmodule Memz.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :owner, :string
      add :end_date, :naive_datetime

      timestamps()
    end

  end
end
