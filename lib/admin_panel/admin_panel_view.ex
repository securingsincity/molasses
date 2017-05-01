defmodule Molasses.AdminPanel.AdminPanelView do
  use Phoenix.View, root: "lib/admin_panel/templates"

  # Import convenience functions from controllers
  import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
  def build_url(conn, path) do
    "/" <> Enum.join(conn.path_info) <> "/#{path}"
  end

  def parent_url(conn, toggle) do
    url = conn.path_info
    |> Enum.join()
    |> String.replace_trailing(toggle, "")
    "/" <> url
  end

  def active(toggle) do
    case toggle do
      true ->
        ~s"""
        <span class="label label-success">ON</span>
        """
      false ->
        ~s"""
        <span class="label label-success">OFF</span>
        """
    end
  end
  import Molasses.Router.Helpers
end