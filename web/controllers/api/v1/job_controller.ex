defmodule Api.V1.JobController do
  use Opencov.Web, :controller

  def create(conn, %{"json" => json}) do
    json = Poison.decode!(json)
    handle_create(conn, json)
  end

  def create(conn, %{"json_file" => %Plug.Upload{path: filepath}}) do
    json = filepath |> File.read! |> Poison.decode!
    handle_create(conn, json)
  end

  def create(conn, _) do
    conn |> bad_request("request should have 'json' or 'json_file' parameter")
  end

  defp handle_create(conn, %{"repo_token" => token} = params) do
    project = Opencov.Project.find_by_token!(token)
    {_, job} = Opencov.Project.add_job!(project, params)
    render conn, "show.json", job: job
  end

  defp handle_create(conn, _) do
    conn |> bad_request("missing 'repo_token' parameter")
  end

  defp bad_request(conn, message) do
    conn
      |> put_status(400)
      |> json %{"error" => message}
  end
end
