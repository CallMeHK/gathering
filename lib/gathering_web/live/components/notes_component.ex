defmodule GatheringWeb.NotesLiveComponent do
  use Phoenix.LiveComponent
  # this alias allows us to use %Notes
  alias Gathering.Notes
  # alias Gathering.MTGRepo


  def preload(list_of_assigns) do
    # IO.puts("PRELOAD DATA")
    # IO.inspect(list_of_assigns)

    list_of_assigns
  end

  def mount(socket) do
    # IO.puts("MOUNT DATA")
    # IO.inspect(socket, structs: false)
    {:ok, socket |> assign(:mounted, false)}
  end

  # to behave the way we want it to, update needs to have 3 lifecycle hook versions
  # of its self:
  # 1. a mounted version because mount is not prop aware (wtf)
  # 2. an update to handle events broadcasted from this component, then thrown back down by liveview parent (wtf)
  # 3. an update that just merges assigns and socket.
  def update(assigns, %{ assigns: %{mounted: false}} = socket) do
    session_notes = Notes.get_session_notes(assigns.session)

    {:ok,
    socket
    |> assign(:session, assigns.session)
    |> assign(:notes, Enum.reverse(session_notes))
    |> assign(:text, "")
    |> assign(:props, assigns)
    |> assign(:mounted, true)}
  end

  def update(%{app_event: :note_added, payload: payload} = assigns, socket) do
    # IO.puts("EVENT UPDATE DATA")
    # IO.inspect(assigns, structs: false)
    # IO.inspect(socket, structs: false)
    {:ok, socket
    |> assign(:notes, [payload | socket.assigns.notes])
    |> assign(:props, assigns) }
  end

  # update statement replaces parent send_update statemetn completely,
  # which merges props into state. perhaps sould update template to not pass
  # props, but then merge all bs
  def update(assigns, socket) do
    # IO.puts("UPDATE DATA")
    # IO.inspect(assigns, structs: false)
    # IO.inspect(socket, structs: false)
    {:ok, socket |> assign(:props, assigns) }
  end

  def handle_event("update_text", %{"note" => note} = _, socket) do
    {:noreply, socket |> assign(:text, note)}
  end

  def handle_event("submit_note", %{"note" => note} = _, socket) do
    _created_note = Notes.create_note(note, socket.assigns.session)
    session = socket.assigns.session

    # response = Gathering.Cards.match(note)
    # IO.inspect(response, structs: false)

    Phoenix.PubSub.broadcast(Gathering.PubSub, "session_#{session}", %{app_event: :note_added, cid: :notes_component, payload: note})
    {:noreply, socket |> assign(:text, "")}
  end

  def render(assigns) do
    # IO.puts("RENDER DATA")
    # IO.inspect(assigns, structs: false)

    ~L"""
    <div>
      <label>Add a note</label>
      <form
        id="notes-form"
        autocomplete="off"
        phx-change="update_text"
        phx-submit="submit_note"
        phx-target="<%= @myself %>">
        <input
          id="notes-input"
          type="text"
          style="width:350px"
          name="note"
          value="<%= @text %>"
          >
      </form>
    </div>
    <div>
      <ul>
        <%= for note <- @notes do %>
          <li> <%= note %>
        <% end %>
      </ul>
    </div>
    <script>
      function logSubmit(event) {
        document.getElementById('notes-input').focus()
      }

      const form = document.getElementById('notes-form')
      form.addEventListener('submit', logSubmit)
    </script>
    """
  end
end
