defmodule GatheringWeb.NotesLiveComponent do
  use Phoenix.LiveComponent
  # this alias allows us to use %Notes
  alias Gathering.Notes


  # def handle_params(_,_,socket) do


  #   Phoenix.PubSub.subscribe(Gathering.PubSub, "req_id_default")
  #   {:noreply,
  #   socket
  #   |> assign(:req_id, "default")}
  # end
  def preload(list_of_assigns) do
    # IO.puts("PRELOAD DATA")
    # IO.puts("----------------")
    # IO.inspect(list_of_assigns)
    # IO.puts("----------------")
    # IO.puts("")

    list_of_assigns
  end

  def mount(socket) do
    # IO.puts("MOUNT DATA")
    # IO.puts("----------------")
    # IO.inspect(socket, structs: false)
    # IO.puts("----------------")
    # IO.puts("")
    # session = socket.assigns.props["session"]
    # Phoenix.PubSub.subscribe(Gathering.PubSub, "session_#{session}")
    # |> assign(:session, session)
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

    Phoenix.PubSub.broadcast(Gathering.PubSub, "session_#{session}", %{app_event: :note_added, cid: socket.assigns.props.id, payload: note})
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
        phx-change="update_text"
        phx-submit="submit_note"
        phx-target="<%= @myself %>">
        <input
          id="notes-input"
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
