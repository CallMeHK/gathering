defmodule Gathering.Session do
  use Ecto.Schema
  import Ecto.Changeset
  # this alias allows us to use %Session
  alias Gathering.Session
  # this alias allows us to use Repo.Stuff
  alias Gathering.Repo

  schema "session" do
    field :name, :string
    field :session, :string

    has_many :notes, Gathering.Notes

    timestamps()
  end

  @doc false
  def changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:name, :session])
    |> validate_required([:session])
  end

  def create_session(session_name, session) do
    new_session = changeset(%Session{}, %{name: session_name, session: session})
    Repo.insert(new_session)
  end
end
