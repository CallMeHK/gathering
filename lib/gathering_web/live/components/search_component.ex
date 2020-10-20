defmodule GatheringWeb.SearchLiveComponent do
  use Phoenix.LiveComponent
  # this alias allows us to use %Notes
  # alias Gathering.Notes
  # alias Gathering.MTGRepo


  def preload(list_of_assigns) do
    list_of_assigns
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:timer_ref, nil)
     |> assign(:results, [])
     |> assign(:loading, false)
     |> assign(:mounted, false)}
  end

  def update(%{session: session} = assigns, %{ assigns: %{mounted: false}} = socket) do
    {:ok,
    socket
    |> assign(:props, assigns)
    |> assign(:session, session)
    |> assign(:mounted, true)}
  end

  def update(%{app_event: :debounced_search} = assigns, socket) do

    response = Gathering.Cards.match_dedupe(socket.assigns.query)

    {:ok,
    socket
    |> assign(:results, response)
    |> assign(:timer_ref, nil)
    |> assign(:props, assigns) }
  end


  def update(assigns, socket) do
    {:ok, socket |> assign(:props, assigns) }
  end

  # def handle_event("search", %{"card-input" => q}, %{assigns: %{loading: true}} = socket) do
  #   socket = socket |> assign(:query, q)

  #   {:noreply, socket}
  # end

  def handle_event("search_cards", %{ "card-input" => q}, %{assigns: %{loading: _}} = socket) do
    if socket.assigns.timer_ref != nil, do: Process.cancel_timer(socket.assigns.timer_ref)
    # debounce time of 300 ms
    timer_ref = Process.send_after(self(), %{app_event: :debounced_search, cid: :search_component, payload: %{} }, 500)
    {:noreply, socket
    |> assign(:query, q)
    |> assign(:timer_ref, timer_ref)
    |> assign(:loading, true)}
  end

  def handle_event("submit_card", %{"card-input" => selected_card_name} = _assigns, %{ assigns: %{results: results, session: session}} = socket) do
    # IO.puts "SUBMIT_CARD EVENT"
    selected_card = Enum.find( results, fn (result) -> match?({_, ^selected_card_name, _}, result) end )
    Phoenix.PubSub.broadcast(Gathering.PubSub,
     "session_#{session}",
     %{app_event: :card_added,
      cid: :search_component,
      payload: selected_card
     })

    {:noreply, socket
    |> assign(:query, "")
    |> assign(:results, [])
    |> assign(:timer_ref, nil)}
  end


  def handle_event("select_datalist", assigns, socket) do
    IO.puts "SELECT_DATALIST EVENT"
    IO.inspect assigns, structs: false
    {:noreply, socket}
  end

  def should_render_datalist("" = _query, _result) do
    false
  end

  # def should_render_datalist(_query, result) when first(result) == nil, do: false

  def should_render_datalist(query, results) do
    if length(results) > 1 do
      true
    else
      first_result = List.first(results)
      case first_result do
        {_, card_name, _ } -> card_name != query
        nil -> false
      end
    end
  end

  def render(assigns) do

    ~L"""
    <div>
      <label>Add a card</label>
      <form phx-change="search_cards" phx-submit="submit_card" phx-target="<%= @myself %>">
        <input
         type="text"
         style="width:350px"
         name="card-input"
         value="<%= @query %>"
         placeholder="Live card search"
         list="results"
         autocomplete="off"
         />
         <%= if GatheringWeb.SearchLiveComponent.should_render_datalist(@query, @results) do %>
          <datalist id="results" phx-input="select_datalist">
            <%= for {_, card_name, _} <- @results do %>
              <option tabindex="0" value="<%= card_name %>"><%= card_name %></option>
            <% end %>
          </datalist>
        <% end %>
      </form>
    </div>
   """
  end
end
