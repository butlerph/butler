defimpl Canada.Can, for: Butler.Accounts.User do
  alias Butler.Accounts.User
  alias Butler.Schedules.Todo

  def can?(%User{role: :user}, :create, Todo), do: true

  def can?(_, _, _), do: false
end
