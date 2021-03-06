defmodule ButlerWeb.TodoLive.FormComponent do
  use ButlerWeb, :live_component

  import Canada.Can, only: [can?: 3]

  alias Butler.Schedules
  alias Butler.Schedules.Todo
  alias Butler.Accounts.User

  @impl true
  def update(%{todo: todo} = assigns, socket) do
    changeset = Schedules.change_todo(todo, %{user: assigns.current_user})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate_todo", %{"todo" => todo_params}, socket) do
    todo_params =
      todo_params
      |> Map.put("user_id", socket.assigns.current_user)
      |> Map.update("duration", 15, fn
        "" -> ""
        d ->
          String.to_integer(d)
      end)

    changeset = Schedules.change_todo(socket.assigns.todo, todo_params)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save_todo", %{"todo" => todo_params}, socket) do
    save_todo(socket, socket.assigns.action, todo_params)
  end

  def save_todo(socket, :new, todo_params) do
    todo_params = Map.update(todo_params, "duration", 15, &String.to_integer(&1))

    with %User{} = current_user <- Map.get(socket.assigns, :current_user),
         true <- can?(current_user, :create, Todo),
         todo_params <- Map.put(todo_params, "user_id", current_user.id),
         {:ok, _todo} <- Schedules.create_todo(todo_params) do
      {:noreply,
        socket
        |> put_flash(:info, "Todo created successfully")
        |> push_redirect(to: Routes.todo_index_path(socket, :index))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      _ ->
        {:noreply,
          socket
          |> put_flash(:error, "You're not allowed to do that.")
          |> push_redirect(to: socket.assigns.return_to)}
    end
  end

  def save_todo(socket, :edit, todo_params) do
    case Schedules.update_todo(socket.assigns.todo, todo_params) do
      {:ok, _todo} ->
        todos = ButlerWeb.TodoLive.Index.run_scheduler(socket.assigns.current_user.id)

        {:noreply,
          socket
          |> assign(:todos, todos)
          |> put_flash(:info, "It has been updated. I also rescheduled your calendar! 😊")
          |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp list_priorities do
    ["None": :none, "Low": :low, "Medium": :medium, "High": :high]
  end

  defp get_submit_name(:new), do: "Add"
  defp get_submit_name(:edit), do: "Update"
end
