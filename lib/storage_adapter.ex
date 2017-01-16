defmodule Molasses.StorageAdapter do

  @type value :: any
  @type key :: any


  @callback get(key) :: {:ok, term} | {:error, term}
  @callback set(key, value) :: {:ok, term} | {:error, term}
  @callback remove(key) :: {:ok, true} | {:error, false}
end
