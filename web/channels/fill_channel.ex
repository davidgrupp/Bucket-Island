defmodule BucketIsland.FillChannel do
  use Phoenix.Channel
  require Logger

  def join("fill:lobby", message, socket) do
    Process.flag(:trap_exit, true)
    :timer.send_interval(5000, :ping)
    :timer.send_interval(1000, :total_clicks)
    send(self, {:after_join, message})

    {:ok, socket}
  end

  def join("fill:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_info(:ping, socket) do
    push socket, "new:msg", %{user: "SYSTEM", body: "ping"}
    {:noreply, socket}
  end

   def handle_info(:total_clicks, socket) do
    total_clicks = 5554123456789012345678
    push socket, "update:total_clicks", %{user: "SYSTEM", body: %{"total_clicks": Integer.to_string(total_clicks)}}
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_in("new:msg", msg, socket) do
    broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{msg: msg["body"]}}, assign(socket, :user, msg["user"])}
  end

  def handle_in("new:click",%{"hash" => hash, "next_click_hash" => next_click_hash, "user" => user}, socket) do
    # broadcast! socket, "new:msg", %{user: msg["user"], body: msg["body"]}
    {:reply, {:ok, %{"next_click_hash": next_click_hash}}, assign(socket, :user, user)}
  end
end