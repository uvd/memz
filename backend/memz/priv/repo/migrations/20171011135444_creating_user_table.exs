defmodule Memz.Repo.Migrations.CreatingUserTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
    end
  end
end
