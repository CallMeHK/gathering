defmodule Gathering.Repo.Migrations.ChangeNoteToText do
  use Ecto.Migration

  def change do
    alter table(:notes) do
      modify :text, :text
    end
  end
end
