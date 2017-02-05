defmodule Molasses.Util do
  def convert_to_list(""), do: []
  def convert_to_list(nil), do: []
  def convert_to_list(non_empty_string) do
    non_empty_string
    |> String.split(",")
  end


  def return_bool("true"), do: true
  def return_bool("false"), do: false
end
