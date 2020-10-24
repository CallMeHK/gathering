defmodule Gathering.Cards do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]
  # this alias allows us to use %Session
  # alias Gathering.Cards
  # this alias allows us to use Repo.Stuff
  alias Gathering.MTGRepo

  schema "cards" do
    field :name, :string
  end

  def find(card_name) do
    query = from c in "cards",
     select: {c.id, c.artist, c.name},
     where: c.name == ^card_name
    MTGRepo.all(query)
  end

  def match(substring) do
    query_string ="%" <> substring <> "%"
    query = from c in "cards",
     select: { c.id, c.name, c.scryfallId },
     where: like(c.name, ^query_string),
     limit: 100
    MTGRepo.all(query)
  end

  def match_dedupe("" = _substring) do
    []
  end

  def match_dedupe(substring) do
    duped_matches = Gathering.Cards.match(substring)
    Enum.reduce duped_matches, [], fn({_, card_name, _} = elt, acc) ->
      is_in_acc = Enum.member?(
         Enum.map(acc, fn({_, map_card_name, _}) -> map_card_name end),
         card_name)
      if !is_in_acc, do: [elt | acc], else: acc
    end
  end
end
