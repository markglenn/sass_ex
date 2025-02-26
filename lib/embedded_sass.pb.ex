defmodule Sass.EmbeddedProtocol.OutputStyle do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:EXPANDED, 0)
  field(:COMPRESSED, 1)
end

defmodule Sass.EmbeddedProtocol.Syntax do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:SCSS, 0)
  field(:INDENTED, 1)
  field(:CSS, 2)
end

defmodule Sass.EmbeddedProtocol.LogEventType do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:WARNING, 0)
  field(:DEPRECATION_WARNING, 1)
  field(:DEBUG, 2)
end

defmodule Sass.EmbeddedProtocol.ProtocolErrorType do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:PARSE, 0)
  field(:PARAMS, 1)
  field(:INTERNAL, 2)
end

defmodule Sass.EmbeddedProtocol.ListSeparator do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:COMMA, 0)
  field(:SPACE, 1)
  field(:SLASH, 2)
  field(:UNDECIDED, 3)
end

defmodule Sass.EmbeddedProtocol.SingletonValue do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:TRUE, 0)
  field(:FALSE, 1)
  field(:NULL, 2)
end

defmodule Sass.EmbeddedProtocol.CalculationOperator do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:PLUS, 0)
  field(:MINUS, 1)
  field(:TIMES, 2)
  field(:DIVIDE, 3)
end

defmodule Sass.EmbeddedProtocol.InboundMessage.VersionRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest.StringInput do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:source, 1, type: :string)
  field(:url, 2, type: :string)
  field(:syntax, 3, type: Sass.EmbeddedProtocol.Syntax, enum: true)
  field(:importer, 4, type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer)
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:importer, 0)

  field(:path, 1, type: :string, oneof: 0)
  field(:importer_id, 2, type: :uint32, json_name: "importerId", oneof: 0)
  field(:file_importer_id, 3, type: :uint32, json_name: "fileImporterId", oneof: 0)

  field(:node_package_importer, 5,
    type: Sass.EmbeddedProtocol.NodePackageImporter,
    json_name: "nodePackageImporter",
    oneof: 0
  )

  field(:non_canonical_scheme, 4, repeated: true, type: :string, json_name: "nonCanonicalScheme")
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:input, 0)

  field(:string, 2,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.StringInput,
    oneof: 0
  )

  field(:path, 3, type: :string, oneof: 0)
  field(:style, 4, type: Sass.EmbeddedProtocol.OutputStyle, enum: true)
  field(:source_map, 5, type: :bool, json_name: "sourceMap")

  field(:importers, 6,
    repeated: true,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer
  )

  field(:global_functions, 7, repeated: true, type: :string, json_name: "globalFunctions")
  field(:alert_color, 8, type: :bool, json_name: "alertColor")
  field(:alert_ascii, 9, type: :bool, json_name: "alertAscii")
  field(:verbose, 10, type: :bool)
  field(:quiet_deps, 11, type: :bool, json_name: "quietDeps")
  field(:source_map_include_sources, 12, type: :bool, json_name: "sourceMapIncludeSources")
  field(:charset, 13, type: :bool)
  field(:silent, 14, type: :bool)
  field(:fatal_deprecation, 15, repeated: true, type: :string, json_name: "fatalDeprecation")
  field(:silence_deprecation, 16, repeated: true, type: :string, json_name: "silenceDeprecation")
  field(:future_deprecation, 17, repeated: true, type: :string, json_name: "futureDeprecation")
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CanonicalizeResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:result, 0)

  field(:id, 1, type: :uint32)
  field(:url, 2, type: :string, oneof: 0)
  field(:error, 3, type: :string, oneof: 0)
  field(:containing_url_unused, 4, type: :bool, json_name: "containingUrlUnused")
end

defmodule Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:contents, 1, type: :string)
  field(:syntax, 2, type: Sass.EmbeddedProtocol.Syntax, enum: true)
  field(:source_map_url, 3, proto3_optional: true, type: :string, json_name: "sourceMapUrl")
end

defmodule Sass.EmbeddedProtocol.InboundMessage.ImportResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:result, 0)

  field(:id, 1, type: :uint32)

  field(:success, 2,
    type: Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess,
    oneof: 0
  )

  field(:error, 3, type: :string, oneof: 0)
end

defmodule Sass.EmbeddedProtocol.InboundMessage.FileImportResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:result, 0)

  field(:id, 1, type: :uint32)
  field(:file_url, 2, type: :string, json_name: "fileUrl", oneof: 0)
  field(:error, 3, type: :string, oneof: 0)
  field(:containing_url_unused, 4, type: :bool, json_name: "containingUrlUnused")
end

defmodule Sass.EmbeddedProtocol.InboundMessage.FunctionCallResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:result, 0)

  field(:id, 1, type: :uint32)
  field(:success, 2, type: Sass.EmbeddedProtocol.Value, oneof: 0)
  field(:error, 3, type: :string, oneof: 0)

  field(:accessed_argument_lists, 4,
    repeated: true,
    type: :uint32,
    json_name: "accessedArgumentLists"
  )
end

defmodule Sass.EmbeddedProtocol.InboundMessage do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:message, 0)

  field(:compile_request, 2,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest,
    json_name: "compileRequest",
    oneof: 0
  )

  field(:canonicalize_response, 3,
    type: Sass.EmbeddedProtocol.InboundMessage.CanonicalizeResponse,
    json_name: "canonicalizeResponse",
    oneof: 0
  )

  field(:import_response, 4,
    type: Sass.EmbeddedProtocol.InboundMessage.ImportResponse,
    json_name: "importResponse",
    oneof: 0
  )

  field(:file_import_response, 5,
    type: Sass.EmbeddedProtocol.InboundMessage.FileImportResponse,
    json_name: "fileImportResponse",
    oneof: 0
  )

  field(:function_call_response, 6,
    type: Sass.EmbeddedProtocol.InboundMessage.FunctionCallResponse,
    json_name: "functionCallResponse",
    oneof: 0
  )

  field(:version_request, 7,
    type: Sass.EmbeddedProtocol.InboundMessage.VersionRequest,
    json_name: "versionRequest",
    oneof: 0
  )
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.VersionResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 5, type: :uint32)
  field(:protocol_version, 1, type: :string, json_name: "protocolVersion")
  field(:compiler_version, 2, type: :string, json_name: "compilerVersion")
  field(:implementation_version, 3, type: :string, json_name: "implementationVersion")
  field(:implementation_name, 4, type: :string, json_name: "implementationName")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileSuccess do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:css, 1, type: :string)
  field(:source_map, 2, type: :string, json_name: "sourceMap")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileFailure do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:message, 1, type: :string)
  field(:span, 2, type: Sass.EmbeddedProtocol.SourceSpan)
  field(:stack_trace, 3, type: :string, json_name: "stackTrace")
  field(:formatted, 4, type: :string)
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:result, 0)

  field(:success, 2,
    type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileSuccess,
    oneof: 0
  )

  field(:failure, 3,
    type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileFailure,
    oneof: 0
  )

  field(:loaded_urls, 4, repeated: true, type: :string, json_name: "loadedUrls")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.LogEvent do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:type, 2, type: Sass.EmbeddedProtocol.LogEventType, enum: true)
  field(:message, 3, type: :string)
  field(:span, 4, proto3_optional: true, type: Sass.EmbeddedProtocol.SourceSpan)
  field(:stack_trace, 5, type: :string, json_name: "stackTrace")
  field(:formatted, 6, type: :string)
  field(:deprecation_type, 7, proto3_optional: true, type: :string, json_name: "deprecationType")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CanonicalizeRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
  field(:importer_id, 3, type: :uint32, json_name: "importerId")
  field(:url, 4, type: :string)
  field(:from_import, 5, type: :bool, json_name: "fromImport")
  field(:containing_url, 6, proto3_optional: true, type: :string, json_name: "containingUrl")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.ImportRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
  field(:importer_id, 3, type: :uint32, json_name: "importerId")
  field(:url, 4, type: :string)
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.FileImportRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
  field(:importer_id, 3, type: :uint32, json_name: "importerId")
  field(:url, 4, type: :string)
  field(:from_import, 5, type: :bool, json_name: "fromImport")
  field(:containing_url, 6, proto3_optional: true, type: :string, json_name: "containingUrl")
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.FunctionCallRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:identifier, 0)

  field(:id, 1, type: :uint32)
  field(:name, 3, type: :string, oneof: 0)
  field(:function_id, 4, type: :uint32, json_name: "functionId", oneof: 0)
  field(:arguments, 5, repeated: true, type: Sass.EmbeddedProtocol.Value)
end

defmodule Sass.EmbeddedProtocol.OutboundMessage do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:message, 0)

  field(:error, 1, type: Sass.EmbeddedProtocol.ProtocolError, oneof: 0)

  field(:compile_response, 2,
    type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse,
    json_name: "compileResponse",
    oneof: 0
  )

  field(:log_event, 3,
    type: Sass.EmbeddedProtocol.OutboundMessage.LogEvent,
    json_name: "logEvent",
    oneof: 0
  )

  field(:canonicalize_request, 4,
    type: Sass.EmbeddedProtocol.OutboundMessage.CanonicalizeRequest,
    json_name: "canonicalizeRequest",
    oneof: 0
  )

  field(:import_request, 5,
    type: Sass.EmbeddedProtocol.OutboundMessage.ImportRequest,
    json_name: "importRequest",
    oneof: 0
  )

  field(:file_import_request, 6,
    type: Sass.EmbeddedProtocol.OutboundMessage.FileImportRequest,
    json_name: "fileImportRequest",
    oneof: 0
  )

  field(:function_call_request, 7,
    type: Sass.EmbeddedProtocol.OutboundMessage.FunctionCallRequest,
    json_name: "functionCallRequest",
    oneof: 0
  )

  field(:version_response, 8,
    type: Sass.EmbeddedProtocol.OutboundMessage.VersionResponse,
    json_name: "versionResponse",
    oneof: 0
  )
end

defmodule Sass.EmbeddedProtocol.ProtocolError do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:type, 1, type: Sass.EmbeddedProtocol.ProtocolErrorType, enum: true)
  field(:id, 2, type: :uint32)
  field(:message, 3, type: :string)
end

defmodule Sass.EmbeddedProtocol.SourceSpan.SourceLocation do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:offset, 1, type: :uint32)
  field(:line, 2, type: :uint32)
  field(:column, 3, type: :uint32)
end

defmodule Sass.EmbeddedProtocol.SourceSpan do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:text, 1, type: :string)
  field(:start, 2, type: Sass.EmbeddedProtocol.SourceSpan.SourceLocation)
  field(:end, 3, proto3_optional: true, type: Sass.EmbeddedProtocol.SourceSpan.SourceLocation)
  field(:url, 4, type: :string)
  field(:context, 5, type: :string)
end

defmodule Sass.EmbeddedProtocol.Value.String do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:text, 1, type: :string)
  field(:quoted, 2, type: :bool)
end

defmodule Sass.EmbeddedProtocol.Value.Number do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:value, 1, type: :double)
  field(:numerators, 2, repeated: true, type: :string)
  field(:denominators, 3, repeated: true, type: :string)
end

defmodule Sass.EmbeddedProtocol.Value.Color do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:space, 1, type: :string)
  field(:channel1, 2, proto3_optional: true, type: :double)
  field(:channel2, 3, proto3_optional: true, type: :double)
  field(:channel3, 4, proto3_optional: true, type: :double)
  field(:alpha, 5, proto3_optional: true, type: :double)
end

defmodule Sass.EmbeddedProtocol.Value.List do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:separator, 1, type: Sass.EmbeddedProtocol.ListSeparator, enum: true)
  field(:has_brackets, 2, type: :bool, json_name: "hasBrackets")
  field(:contents, 3, repeated: true, type: Sass.EmbeddedProtocol.Value)
end

defmodule Sass.EmbeddedProtocol.Value.Map.Entry do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:key, 1, type: Sass.EmbeddedProtocol.Value)
  field(:value, 2, type: Sass.EmbeddedProtocol.Value)
end

defmodule Sass.EmbeddedProtocol.Value.Map do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:entries, 1, repeated: true, type: Sass.EmbeddedProtocol.Value.Map.Entry)
end

defmodule Sass.EmbeddedProtocol.Value.CompilerFunction do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
end

defmodule Sass.EmbeddedProtocol.Value.HostFunction do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
  field(:signature, 2, type: :string)
end

defmodule Sass.EmbeddedProtocol.Value.CompilerMixin do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
end

defmodule Sass.EmbeddedProtocol.Value.ArgumentList.KeywordsEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:key, 1, type: :string)
  field(:value, 2, type: Sass.EmbeddedProtocol.Value)
end

defmodule Sass.EmbeddedProtocol.Value.ArgumentList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:id, 1, type: :uint32)
  field(:separator, 2, type: Sass.EmbeddedProtocol.ListSeparator, enum: true)
  field(:contents, 3, repeated: true, type: Sass.EmbeddedProtocol.Value)

  field(:keywords, 4,
    repeated: true,
    type: Sass.EmbeddedProtocol.Value.ArgumentList.KeywordsEntry,
    map: true
  )
end

defmodule Sass.EmbeddedProtocol.Value.Calculation.CalculationValue do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:value, 0)

  field(:number, 1, type: Sass.EmbeddedProtocol.Value.Number, oneof: 0)
  field(:string, 2, type: :string, oneof: 0)
  field(:interpolation, 3, type: :string, oneof: 0)

  field(:operation, 4,
    type: Sass.EmbeddedProtocol.Value.Calculation.CalculationOperation,
    oneof: 0
  )

  field(:calculation, 5, type: Sass.EmbeddedProtocol.Value.Calculation, oneof: 0)
end

defmodule Sass.EmbeddedProtocol.Value.Calculation.CalculationOperation do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:operator, 1, type: Sass.EmbeddedProtocol.CalculationOperator, enum: true)
  field(:left, 2, type: Sass.EmbeddedProtocol.Value.Calculation.CalculationValue)
  field(:right, 3, type: Sass.EmbeddedProtocol.Value.Calculation.CalculationValue)
end

defmodule Sass.EmbeddedProtocol.Value.Calculation do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:name, 1, type: :string)

  field(:arguments, 2,
    repeated: true,
    type: Sass.EmbeddedProtocol.Value.Calculation.CalculationValue
  )
end

defmodule Sass.EmbeddedProtocol.Value do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  oneof(:value, 0)

  field(:string, 1, type: Sass.EmbeddedProtocol.Value.String, oneof: 0)
  field(:number, 2, type: Sass.EmbeddedProtocol.Value.Number, oneof: 0)
  field(:list, 5, type: Sass.EmbeddedProtocol.Value.List, oneof: 0)
  field(:map, 6, type: Sass.EmbeddedProtocol.Value.Map, oneof: 0)
  field(:singleton, 7, type: Sass.EmbeddedProtocol.SingletonValue, enum: true, oneof: 0)

  field(:compiler_function, 8,
    type: Sass.EmbeddedProtocol.Value.CompilerFunction,
    json_name: "compilerFunction",
    oneof: 0
  )

  field(:host_function, 9,
    type: Sass.EmbeddedProtocol.Value.HostFunction,
    json_name: "hostFunction",
    oneof: 0
  )

  field(:argument_list, 10,
    type: Sass.EmbeddedProtocol.Value.ArgumentList,
    json_name: "argumentList",
    oneof: 0
  )

  field(:calculation, 12, type: Sass.EmbeddedProtocol.Value.Calculation, oneof: 0)

  field(:compiler_mixin, 13,
    type: Sass.EmbeddedProtocol.Value.CompilerMixin,
    json_name: "compilerMixin",
    oneof: 0
  )

  field(:color, 14, type: Sass.EmbeddedProtocol.Value.Color, oneof: 0)
end

defmodule Sass.EmbeddedProtocol.NodePackageImporter do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field(:entry_point_directory, 1, type: :string, json_name: "entryPointDirectory")
end
