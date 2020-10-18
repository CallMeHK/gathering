defmodule GatheringWeb.HomeController do
  use GatheringWeb, :controller


  def index(conn, _params) do
    conn
    |> render("index.html")
  end


end
