
# to add a pubsub to phoenix:
# 1. ensure pubsub is in mix.exs deps
# 2. add PubSub line in application.ex
# 3. add pubsub_server to config.exs

# ^^^ none of this is necessary, just use the pubsub that is already in the app
# Im not sure why we would need the PG2 stuff, this default protocol seems to work


defmodule GatheringWeb.RoomLive do
  use Phoenix.LiveView
  alias Gathering.SessionCards

  def mount(%{"session" => session}, _, socket) do
    # socket = assign(socket, :count, 0)
    session_cards = SessionCards.get_cards_by_session(session)
    IO.inspect session_cards
    {:ok, socket
    |> assign(:count, 0)
    |> assign(:cards, session_cards )}
  end

  def handle_params(%{"session" => session},_,socket) do
    Phoenix.PubSub.subscribe(Gathering.PubSub, "session_#{session}")

    {:noreply,
    socket
    |> assign(:session, session)}
  end

  def handle_info(%{app_event: event, cid: :notes_component, payload: payload}, socket)  do

    send_update(GatheringWeb.NotesLiveComponent,
      id: :notes_component,
      app_event: event,
      payload: payload,
      session: socket.assigns.session)
    {:noreply, socket}
  end

  def handle_info(%{app_event: :card_added, cid: :search_component, payload: payload}, socket)  do
    cards = List.flatten([ socket.assigns.cards, payload ])
   {:noreply,
    socket
    |> assign(:cards, cards )}
  end

  def handle_info(%{app_event: event, cid: :search_component, payload: payload}, socket)  do
    send_update(GatheringWeb.SearchLiveComponent,
      id: :search_component,
      app_event: event,
      payload: payload,
      session: socket.assigns.session)
    {:noreply, socket}
  end

  def handle_info(%{app_event: :card_removed, payload: id}, socket)  do
    IO.puts "----------- CARD REMOVED EVENT -----------"
    new_cards = Enum.reduce(socket.assigns.cards, fn ({card_id, _, _} = card, acc) ->
      case card_id do
        ^id -> acc
        _ -> List.flatten([acc, card])
      end
    end)

    {:noreply, socket |> assign(:cards, new_cards)}
  end

  def handle_event("remove_card", %{"value" => id} = _assigns, socket) do
    IO.puts "REMOVE_CARD"
    session = socket.assigns.session
    { int_id, _} = Integer.parse(id)
    SessionCards.delete_card_by_id(int_id)
    Phoenix.PubSub.broadcast(Gathering.PubSub,
        "session_#{session}",
        %{app_event: :card_removed,
        payload: int_id
      })

    {:noreply, socket}
  end
end
