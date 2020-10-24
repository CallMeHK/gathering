defmodule Gathering.Repo.Migrations.CreateSessionCards do
  use Ecto.Migration

  def change do
    create table(:session_cards) do
      add :name, :string
      add :scryfall_id, :string
      add :session, references(:session, type: :string, column: :session, on_delete: :delete_all)
      add :card_id, :integer
      add :player, :integer

      timestamps()
    end

  end
end
