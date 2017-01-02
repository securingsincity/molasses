Application.put_env(:exredis,:host, "127.0.0.1")
Application.put_env(:exredis,:port, 6379)
Application.put_env(:exredis,:password, "")
Application.put_env(:molasses,:adapter, "redis")