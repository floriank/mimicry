defmodule Mimicry.OpenAPI.Parser do
  @moduledoc """
  Parses a given OpenAPI Specification and gives access to the different parts of the spec more easily
  """

  alias Mimicry.OpenAPI.Specification

  require Logger

  def parse(str, atom) do
    str
    |> decoder(atom).()
    |> case do
      {:ok, decoded} ->
        decoded |> build_specification()

      {:error, _} ->
        Logger.warn("Could not decode JSON specification")
        Specification.unsupported()
    end
  end

  defp build_specification(
         parsed = %{"openapi" => openapi_version, "info" => %{"version" => v, "title" => title}}
       ) do
    %Specification{
      version: v,
      title: title,
      openapi_version: openapi_version,
      content: parsed
    }
  end

  defp decoder(atom) do
    case atom do
      # NOTE: This cannot read multiple specifications in a YAML file as of yet
      :yaml -> &YamlElixir.read_from_string/1
      :json -> &Jason.decode/2
    end
  end
end