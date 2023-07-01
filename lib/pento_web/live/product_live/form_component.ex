defmodule PentoWeb.ProductLive.FormComponent do
  use PentoWeb, :live_component

  alias Pento.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        multipart
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />
        <%= for image <- @uploads.image.entries do %>
          <div class="mt-4 w-96 ">
            <.live_img_preview entry={image} class="border border-gray-400 rounded-lg" />
          </div>
          <progress value={image.progress} max="100" class="mt-1 w-96" />
          <%= for err <- upload_errors(@uploads.image, image) do %>
            <.error><%= err %></.error>
          <% end %>
        <% end %>
        <div
          phx-drop-target={@uploads.image.ref}
          class="bg-gray-200 border border-gray-400 rounded-lg p-4 pt-10"
        >
          <.label>Image Upload</.label>
          <.live_file_input upload={@uploads.image} />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png),
       # max_file_size defaults to 8MB
       max_file_size: 9_000_000,
       auto_upload: true
     )}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, params) do
    IO.puts("save_product edit")
    product_params = params_with_image(socket, params)

    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, params) do
    IO.puts("save_product new")
    product_params = params_with_image(socket, params)

    case Catalog.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def params_with_image(socket, params) do
    IO.puts("params_with_image")

    path =
      socket
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first()

    Map.put(params, "image_upload", path)
  end

  defp upload_static_file(%{path: src}, %{client_name: client_name}) do
    IO.puts("upload_static_file")
    # IO.inspect(entry)

    # Plug in your production image file persistence implementation here.
    ext = Path.extname(client_name)
    filename = "#{Path.basename(src)}#{ext}"

    dest = Path.join("priv/static/upload", filename)
    IO.puts("dest: #{dest}")
    File.cp!(src, dest)
    {:ok, ~p"/upload/#{filename}"}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
