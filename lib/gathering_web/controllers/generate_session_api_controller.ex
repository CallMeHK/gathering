defmodule GatheringWeb.GenerateSessionAPIController do
  use GatheringWeb, :controller
  require Logger
  # alias Gathering.Session

  def index(conn, _params) do
    session = GatheringWeb.StringGenerator.string_of_length(13)

    created_session = Gathering.Session.create_session("session", session)

    Logger.debug inspect(created_session)

    case created_session do
      {:ok, data } -> conn |> json(%{success: true, data: %{session: data.session, name: data.name } })
      {:error, _ } -> conn |> json(%{ success: false, error: "Could not create session" })
    end
 end
end
