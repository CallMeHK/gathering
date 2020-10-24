defmodule Gathering.SessionCards do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Gathering.SessionCards
  alias Gathering.Repo

  schema "session_cards" do
    field :card_id, :integer
    field :name, :string
    field :player, :integer
    field :scryfall_id, :string
    field :session, :string

    timestamps()
  end

  @doc false
  def changeset(session_cards, attrs) do
    session_cards
    |> cast(attrs, [:name, :scryfall_id, :session, :card_id, :player])
    |> validate_required([:name, :scryfall_id, :session, :card_id])
  end

  def add_card(%{ name: _name, scryfall_id: _scryfall_id, session: _session, card_id: _card_id } = card) do
    new_card = changeset(%SessionCards{}, card)
    Repo.insert(new_card)
  end

  def get_cards_by_session(session) do
    query = from c in "session_cards", select: { c.id, c.name, c.scryfall_id}, where: c.session == ^session
    Repo.all(query)
  end

  def delete_card_by_id(id) do
    Repo.delete(%SessionCards{id: id})
  end
end
