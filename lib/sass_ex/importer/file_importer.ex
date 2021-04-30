defmodule SassEx.Importer.FileImporter do
  @behaviour SassEx.Importer

  @spec canonicalize(any, binary) :: {:ok, String.t()}
  def canonicalize(_, path), do: {:ok, "file:///" <> path}

  def load(_, "file:///" <> path) do
    case File.read(path) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :file.format_error(error) |> to_string()}
    end
  end
end
