defmodule PentoWeb.FAQLive.Show do
  use PentoWeb, :live_view

  alias Pento.Support

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:faq, Support.get_faq!(id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    faq = Support.get_faq!(id)
    {:ok, _} = Support.delete_faq(faq)

    {:noreply, stream_delete(socket, :faqs, faq)}
  end

  defp page_title(:show), do: "Show Faq"
  defp page_title(:edit), do: "Edit Faq"
end
