defmodule ConnTools do
  def get_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [forwarded_for | _] ->
        String.split(forwarded_for, ",")
        |> List.first()
        |> String.trim()

      _ ->
        conn.remote_ip
        |> Tuple.to_list()
        |> Enum.join(".")
    end
  end
end
