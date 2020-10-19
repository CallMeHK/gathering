
# to add a pubsub to phoenix:
# 1. ensure pubsub is in mix.exs deps
# 2. add PubSub line in application.ex
# 3. add pubsub_server to config.exs

# ^^^ none of this is necessary, just use the pubsub that is already in the app
# Im not sure why we would need the PG2 stuff, this default protocol seems to work


defmodule GatheringWeb.RoomLive do
  use Phoenix.LiveView

  def mount(_session, _, socket) do
    # socket = assign(socket, :count, 0)
    {:ok, socket |> assign(:count, 0)}
  end

  def handle_params(%{"session" => session},_,socket) do
    Phoenix.PubSub.subscribe(Gathering.PubSub, "session_#{session}")

    {:noreply,
    socket
    |> assign(:session, session)}
  end

  def handle_info(%{app_event: event, id: :notes_component, payload: payload}, socket)  do
    send_update(GatheringWeb.NotesLiveComponent,
      id: :notes_component,
      app_event: event,
      payload: payload,
      session: socket.assigns.session)
    {:noreply, socket}
  end

  def handle_info(%{count: count} = _, socket) do
    # send_update(GatheringWeb.NotesLiveComponent,
    #   id: :notes_component,
    #   app_event: :new_note,
    #   payload: socket.assigns.count,
    #   session: socket.assigns.session)
    {:noreply, socket |> assign(:count, count)}
  end

  def handle_event("increment", _, socket) do
    count = socket.assigns.count + 1
    socket = assign(socket, :count, count)
    session = socket.assigns[:session]
    Phoenix.PubSub.broadcast(Gathering.PubSub, "session_#{session}", %{event: "increment", count: count})
    {:noreply, socket}
  end

  def handle_event("decrement", _, socket) do
    count = socket.assigns.count - 1
    socket = assign(socket, :count, count)
    session = socket.assigns[:session]
    Phoenix.PubSub.broadcast(Gathering.PubSub, "session_#{session}", %{event: "decrement", count: count})
    {:noreply, socket}
  end
end
