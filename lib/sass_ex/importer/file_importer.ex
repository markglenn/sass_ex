defmodule SassEx.Importer.FileImporter do
  @behaviour SassEx.Importer

  @spec canonicalize(term, String.t()) :: SassEx.Importer.result_t()
  def canonicalize(_, "file:///" <> _ = path), do: {:ok, path}

  def canonicalize(_, path) do
    case URI.parse(path) do
      %URI{scheme: nil} -> {:ok, "file:///#{path}"}
      _ -> {:error, "Ignoring URI"}
    end
    |> IO.inspect()
  end

  def load(_, "file:///" <> path) do
    IO.inspect(path)

    case File.read(path) do
      {:ok, data} -> {:ok, data}
      {:error, error} -> {:error, :file.format_error(error) |> to_string()}
    end
  end

  def load(_, path), do: IO.inspect(path)
end
