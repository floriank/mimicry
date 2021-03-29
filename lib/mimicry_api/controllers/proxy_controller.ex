defmodule MimicryApi.ProxyController do
  use MimicryApi, :controller

  alias Mimicry.MockServerList

  import MimicryApi.Response, only: [respond_with_mimicry: 3]

  def show(conn = %Plug.Conn{}, params) do
    case conn |> get_req_header("x-mimicry-host") do
      # NOTE: we're taking the first occurence of the header value
      [host | _hosts] ->
        case MockServerList.find_server(host) do
          {:ok, pid} ->
            conn |> respond_with_mimicry(pid, params) |> destructure_response(conn)

          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "No such API available!"})
        end

      [] ->
        conn
        |> json(%{
          message: ~s(Use "X-Mimicry-Host" HTTP header to direct traffic to a registered API)
        })
    end
  end

  defp destructure_response(%{body: body, headers: _headers, status: status}, conn = %Plug.Conn{}) do
    conn |> put_status(status) |> json(body)
  end
end
