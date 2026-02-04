# SPDX-License-Identifier: PMPL-1.0-or-later
defmodule FormdbHttpWeb.UserSocket do
  @moduledoc """
  WebSocket handler for FormDB real-time subscriptions.

  Handles WebSocket connections for journal event streaming.
  """

  use Phoenix.Socket

  ## Channels
  channel "journal:*", FormdbHttpWeb.JournalChannel

  @doc """
  Connect to WebSocket.
  Optionally authenticate with token.
  """
  @impl true
  def connect(params, socket, _connect_info) do
    # Optional: Verify JWT token if authentication is enabled
    case Map.get(params, "token") do
      nil ->
        # No auth required in M13 PoC
        {:ok, socket}

      token ->
        # Verify token if provided
        case FormdbHttpWeb.Auth.JWT.verify_token(token) do
          {:ok, claims} ->
            {:ok, assign(socket, :user_id, Map.get(claims, "sub"))}

          {:error, _} ->
            :error
        end
    end
  end

  @doc """
  Socket ID for identifying connections.
  Used for graceful disconnection.
  """
  @impl true
  def id(socket) do
    case Map.get(socket.assigns, :user_id) do
      nil -> nil  # Anonymous
      user_id -> "user_socket:#{user_id}"
    end
  end
end
