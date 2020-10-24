defmodule GatheringWeb.SearchLiveComponent do
  use Phoenix.LiveComponent
  # this alias allows us to use %Notes
  # alias Gathering.Notes
  # alias Gathering.MTGRepo
  alias Gathering.SessionCards


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
     |> assign(:error, false)
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
    if socket.assigns.timer_ref != nil, do: Process.cancel_timer(socket.assigns.timer_ref)

    downcase_selected_card_name = String.downcase(selected_card_name)
    selected_card = Enum.find( results, fn (result) ->
      {result_id, result_name, result_scryfall_id} = result
      match?({_, ^downcase_selected_card_name, _}, {result_id, String.downcase(result_name), result_scryfall_id })
    end )

    verified_selected_card = case selected_card do
      nil ->
        retry_results = Gathering.Cards.match_dedupe(socket.assigns.query)
        Enum.find( retry_results, fn (result) ->
          {result_id, result_name, result_scryfall_id} = result
          match?({_, ^downcase_selected_card_name, _}, {result_id, String.downcase(result_name), result_scryfall_id })
        end )
      _ ->
        selected_card
    end

    IO.inspect verified_selected_card

    error = if verified_selected_card != nil do
      { card_id, name, scryfall_id} = verified_selected_card

      spawn(fn ->
        added_card = SessionCards.add_card( %{card_id: card_id, name: name, scryfall_id: scryfall_id, session: session })
        case added_card do
          { :ok, card } -> Phoenix.PubSub.broadcast(Gathering.PubSub,
              "session_#{session}",
              %{app_event: :card_added,
              cid: :search_component,
              payload: {card.id, card.name, card.scryfall_id}
            })
          _ -> nil
        end
      end)

      false
    else
      true
    end

    {:noreply, socket
    |> assign(:query, "")
    |> assign(:results, [])
    |> assign(:timer_ref, nil)
    |> assign(:error, error)}
  end

  def should_render_datalist("" = _query, _result) do
    false
  end

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
          <datalist id="results">
            <%= for {_, card_name, _} <- @results do %>
              <option tabindex="0" value="<%= card_name %>"><%= card_name %></option>
            <% end %>
          </datalist>
        <% end %>
      </form>
      <%= if @error do %>
        <div>Invalid card name</div>
      <% end %>
    </div>
   """
  end
end
