defmodule CompanyApiWeb.UserSocket do
  use Phoenix.Socket

  alias CompanyApi.Guardian

  ## Channels
  # channel "room:*", CompanyApiWeb.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case Guardian.Socket.authenticate(socket, Guardian, token) do
      {:ok, socket} ->
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  def connect(_params, socket), do: :error

  def id(socket) do
    user = Guardian.Socket.current_resource(socket)
    #Call GenServer and save socket id
  end
end
