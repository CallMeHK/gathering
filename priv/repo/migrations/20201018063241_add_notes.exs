defmodule Gathering.Repo.Migrations.AddNotes do
  use Ecto.Migration



  def change do
    create unique_index(:session, [:session])

    create table(:notes) do
      add :text, :string
      add :session_id, references(:session, type: :string, column: :session, on_delete: :delete_all)

      timestamps()
    end
  end
end
