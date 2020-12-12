defmodule ButlerWeb.TodoLive.FormComponent do
  use ButlerWeb, :live_component

  alias Butler.Schedules

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    changeset = Schedules.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate_todo", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> Schedules.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save_todo", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.action, todo_params)
  end

  def save_todo(socket, :new, todo_params) do
    todo_params =
      todo_params
      |> Map.update("priority", 1, &String.to_integer(&1))
      |> Map.update("duration", 15, &String.to_integer(&1))

    IO.inspect todo_params, label: "PARAMS"

    send(self(), {:added_todo, todo_params})

    {:noreply,
      socket
      |> put_flash(:info, "Todo added")
      |> push_patch(to: Routes.todo_index_path(socket, :new))
    }
  end

  def save_todo(socket, :edit, todo_params) do
    IO.inspect todo_params, label: "EDIT"

    {:noreply,
      socket
      |> put_flash(:info, "Todo updated successfully!")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end

  defp list_priorities do
    ["None": 1, "Low": 2, "Medium": 3, "High": 4]
  end

  # defp save_todo(socket, :edit, todo_params) do
  #   case Schedules.update_todo(socket.assigns.todo, todo_params) do
  #     {:ok, _todo} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Todo updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  # defp save_todo(socket, :new, todo_params) do
  #   case Schedules.create_todo(todo_params) do
  #     {:ok, _todo} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Todo created successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, changeset: changeset)}
  #   end
  # end
end
