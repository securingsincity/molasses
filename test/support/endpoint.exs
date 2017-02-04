defmodule Molasses.Test.Endpoint do
  use Phoenix.Endpoint, otp_app: :molasses


  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :molasses, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)


  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_binaryid_key",
    signing_salt: "JFbk5iZ6"

  plug Molasses.Test.Router
end

