defmodule Memz.Repo.Migrations.AddedImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :file, :string

      add :user_id, references(:users), null: false
      add :event_id, references(:users), null: false


      timestamps()
    end

    create index(:images, [:user_id])
    create index(:images, [:event_id])

  end

end
