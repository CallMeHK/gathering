defmodule Gathering.Notes do
  use Ecto.Schema
  # import Ecto.Changeset
  # # this alias allows us to use %Session
  # alias Gathering.Notes
  # # this alias allows us to use Repo.Stuff
  # alias Gathering.Repo

  schema "notes" do
    field :text, :string

    belongs_to :session, Gathering.Session

    timestamps()
  end

  # @doc false
  # def changeset(%Notes{} = notes, attrs) do
  #   notes
  #   |> cast(attrs, [:text, :session_id])
  #   |> validate_required([:text, :session_id])
  # end

  # # session_id is session.id, not session.session
  # def create_notes(text, session_id) do
  #   new_notes = changeset(%Notes{}, %{text: text, session_id: session_id})
  #   Repo.insert(new_session)
  # end
end
