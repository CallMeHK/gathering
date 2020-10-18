defmodule Gathering.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:session) do
      add :name, :string
      add :session, :string

      timestamps()
    end

  end
end
