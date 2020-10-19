defmodule Gathering.Notes do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  @foreign_key_type :string
  # this alias allows us to use %Notes
  alias Gathering.Notes
  # this alias allows us to use Repo.Stuff
  alias Gathering.Repo

  schema "notes" do
    field :text, :string

    belongs_to :session, Gathering.Session

    timestamps()
  end

  @doc false
  def changeset(%Notes{} = notes, attrs) do
    notes
    |> cast(attrs, [:text, :session_id])
    |> validate_required([:text, :session_id])
    |> foreign_key_constraint(:session_id)
  end

  # session_id is session.id, not session.session
  def create_note(text, session_id) do
    new_notes = changeset(%Notes{}, %{text: text, session_id: session_id})
    Repo.insert(new_notes)
  end

  def get_session_notes(session_id) do
    query = from n in "notes", select: n.text, where: n.session_id == ^session_id
    Repo.all(query)
  end
end
