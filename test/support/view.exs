defmodule Molasses.ErrorView do
  import Molasses.Router.Helpers
  def render("404.html", _assigns) do
    "Page not found"
  end

  def render("500.json", _assigns) do
    "Server internal error"
  end

  def render("403.html", _assigns) do
    "Forbidden Request"
  end

  def render("400.json", _assigns) do
    %{status: "failure"}
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end