defmodule Sass.EmbeddedProtocol.InboundMessage.Syntax do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :SCSS | :INDENTED | :CSS

  field :SCSS, 0

  field :INDENTED, 1

  field :CSS, 2
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest.OutputStyle do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :EXPANDED | :COMPRESSED

  field :EXPANDED, 0

  field :COMPRESSED, 1
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.LogEvent.Type do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :WARNING | :DEPRECATION_WARNING | :DEBUG

  field :WARNING, 0

  field :DEPRECATION_WARNING, 1

  field :DEBUG, 2
end

defmodule Sass.EmbeddedProtocol.ProtocolError.ErrorType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :PARSE | :PARAMS | :INTERNAL

  field :PARSE, 0

  field :PARAMS, 1

  field :INTERNAL, 2
end

defmodule Sass.EmbeddedProtocol.Value.Singleton do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :TRUE | :FALSE | :NULL

  field :TRUE, 0

  field :FALSE, 1

  field :NULL, 2
end

defmodule Sass.EmbeddedProtocol.Value.List.Separator do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :COMMA | :SPACE | :SLASH | :UNDECIDED

  field :COMMA, 0

  field :SPACE, 1

  field :SLASH, 2

  field :UNDECIDED, 3
end

defmodule Sass.EmbeddedProtocol.InboundMessage.VersionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3
  @type t :: %__MODULE__{}

  defstruct []
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest.StringInput do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          source: String.t(),
          url: String.t(),
          syntax: Sass.EmbeddedProtocol.InboundMessage.Syntax.t(),
          importer: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer.t() | nil
        }

  defstruct [:source, :url, :syntax, :importer]

  field :source, 1, type: :string
  field :url, 2, type: :string
  field :syntax, 3, type: Sass.EmbeddedProtocol.InboundMessage.Syntax, enum: true
  field :importer, 4, type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          importer: {atom, any}
        }

  defstruct [:importer]

  oneof :importer, 0
  field :path, 1, type: :string, oneof: 0
  field :importer_id, 2, type: :uint32, oneof: 0
  field :file_importer_id, 3, type: :uint32, oneof: 0
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CompileRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          input: {atom, any},
          id: non_neg_integer,
          style: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.OutputStyle.t(),
          source_map: boolean,
          importers: [Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer.t()],
          global_functions: [String.t()],
          alert_color: boolean,
          alert_ascii: boolean
        }

  defstruct [
    :input,
    :id,
    :style,
    :source_map,
    :importers,
    :global_functions,
    :alert_color,
    :alert_ascii
  ]

  oneof :input, 0
  field :id, 1, type: :uint32

  field :string, 2,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.StringInput,
    oneof: 0

  field :path, 3, type: :string, oneof: 0

  field :style, 4,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.OutputStyle,
    enum: true

  field :source_map, 5, type: :bool

  field :importers, 6,
    repeated: true,
    type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest.Importer

  field :global_functions, 7, repeated: true, type: :string
  field :alert_color, 8, type: :bool
  field :alert_ascii, 9, type: :bool
end

defmodule Sass.EmbeddedProtocol.InboundMessage.CanonicalizeResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any},
          id: non_neg_integer
        }

  defstruct [:result, :id]

  oneof :result, 0
  field :id, 1, type: :uint32
  field :url, 2, type: :string, oneof: 0
  field :error, 3, type: :string, oneof: 0
end

defmodule Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          contents: String.t(),
          syntax: Sass.EmbeddedProtocol.InboundMessage.Syntax.t(),
          sourceMapUrl: String.t()
        }

  defstruct [:contents, :syntax, :sourceMapUrl]

  field :contents, 1, type: :string
  field :syntax, 2, type: Sass.EmbeddedProtocol.InboundMessage.Syntax, enum: true
  field :sourceMapUrl, 3, type: :string
end

defmodule Sass.EmbeddedProtocol.InboundMessage.ImportResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any},
          id: non_neg_integer
        }

  defstruct [:result, :id]

  oneof :result, 0
  field :id, 1, type: :uint32

  field :success, 2,
    type: Sass.EmbeddedProtocol.InboundMessage.ImportResponse.ImportSuccess,
    oneof: 0

  field :error, 3, type: :string, oneof: 0
end

defmodule Sass.EmbeddedProtocol.InboundMessage.FileImportResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any},
          id: non_neg_integer
        }

  defstruct [:result, :id]

  oneof :result, 0
  field :id, 1, type: :uint32
  field :file_url, 2, type: :string, oneof: 0
  field :error, 3, type: :string, oneof: 0
end

defmodule Sass.EmbeddedProtocol.InboundMessage.FunctionCallResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any},
          id: non_neg_integer
        }

  defstruct [:result, :id]

  oneof :result, 0
  field :id, 1, type: :uint32
  field :success, 2, type: Sass.EmbeddedProtocol.Value, oneof: 0
  field :error, 3, type: :string, oneof: 0
end

defmodule Sass.EmbeddedProtocol.InboundMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  oneof :message, 0
  field :compileRequest, 2, type: Sass.EmbeddedProtocol.InboundMessage.CompileRequest, oneof: 0

  field :canonicalizeResponse, 3,
    type: Sass.EmbeddedProtocol.InboundMessage.CanonicalizeResponse,
    oneof: 0

  field :importResponse, 4, type: Sass.EmbeddedProtocol.InboundMessage.ImportResponse, oneof: 0

  field :fileImportResponse, 5,
    type: Sass.EmbeddedProtocol.InboundMessage.FileImportResponse,
    oneof: 0

  field :functionCallResponse, 6,
    type: Sass.EmbeddedProtocol.InboundMessage.FunctionCallResponse,
    oneof: 0

  field :versionRequest, 7, type: Sass.EmbeddedProtocol.InboundMessage.VersionRequest, oneof: 0
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.VersionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          protocol_version: String.t(),
          compiler_version: String.t(),
          implementation_version: String.t(),
          implementation_name: String.t()
        }

  defstruct [:protocol_version, :compiler_version, :implementation_version, :implementation_name]

  field :protocol_version, 1, type: :string
  field :compiler_version, 2, type: :string
  field :implementation_version, 3, type: :string
  field :implementation_name, 4, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileSuccess do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          css: String.t(),
          source_map: String.t()
        }

  defstruct [:css, :source_map]

  field :css, 1, type: :string
  field :source_map, 2, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileFailure do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: String.t(),
          span: Sass.EmbeddedProtocol.SourceSpan.t() | nil,
          stack_trace: String.t(),
          formatted: String.t()
        }

  defstruct [:message, :span, :stack_trace, :formatted]

  field :message, 1, type: :string
  field :span, 2, type: Sass.EmbeddedProtocol.SourceSpan
  field :stack_trace, 3, type: :string
  field :formatted, 4, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CompileResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any},
          id: non_neg_integer
        }

  defstruct [:result, :id]

  oneof :result, 0
  field :id, 1, type: :uint32

  field :success, 2,
    type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileSuccess,
    oneof: 0

  field :failure, 3,
    type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse.CompileFailure,
    oneof: 0
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.LogEvent do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          compilation_id: non_neg_integer,
          type: Sass.EmbeddedProtocol.OutboundMessage.LogEvent.Type.t(),
          message: String.t(),
          span: Sass.EmbeddedProtocol.SourceSpan.t() | nil,
          stack_trace: String.t(),
          formatted: String.t()
        }

  defstruct [:compilation_id, :type, :message, :span, :stack_trace, :formatted]

  field :compilation_id, 1, type: :uint32
  field :type, 2, type: Sass.EmbeddedProtocol.OutboundMessage.LogEvent.Type, enum: true
  field :message, 3, type: :string
  field :span, 4, type: Sass.EmbeddedProtocol.SourceSpan
  field :stack_trace, 5, type: :string
  field :formatted, 6, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.CanonicalizeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          compilation_id: non_neg_integer,
          importer_id: non_neg_integer,
          url: String.t()
        }

  defstruct [:id, :compilation_id, :importer_id, :url]

  field :id, 1, type: :uint32
  field :compilation_id, 2, type: :uint32
  field :importer_id, 3, type: :uint32
  field :url, 4, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.ImportRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          compilation_id: non_neg_integer,
          importer_id: non_neg_integer,
          url: String.t()
        }

  defstruct [:id, :compilation_id, :importer_id, :url]

  field :id, 1, type: :uint32
  field :compilation_id, 2, type: :uint32
  field :importer_id, 3, type: :uint32
  field :url, 4, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.FileImportRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          compilation_id: non_neg_integer,
          importer_id: non_neg_integer,
          url: String.t()
        }

  defstruct [:id, :compilation_id, :importer_id, :url]

  field :id, 1, type: :uint32
  field :compilation_id, 2, type: :uint32
  field :importer_id, 3, type: :uint32
  field :url, 4, type: :string
end

defmodule Sass.EmbeddedProtocol.OutboundMessage.FunctionCallRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          identifier: {atom, any},
          id: non_neg_integer,
          compilation_id: non_neg_integer,
          arguments: [Sass.EmbeddedProtocol.Value.t()]
        }

  defstruct [:identifier, :id, :compilation_id, :arguments]

  oneof :identifier, 0
  field :id, 1, type: :uint32
  field :compilation_id, 2, type: :uint32
  field :name, 3, type: :string, oneof: 0
  field :function_id, 4, type: :uint32, oneof: 0
  field :arguments, 5, repeated: true, type: Sass.EmbeddedProtocol.Value
end

defmodule Sass.EmbeddedProtocol.OutboundMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }

  defstruct [:message]

  oneof :message, 0
  field :error, 1, type: Sass.EmbeddedProtocol.ProtocolError, oneof: 0
  field :compileResponse, 2, type: Sass.EmbeddedProtocol.OutboundMessage.CompileResponse, oneof: 0
  field :logEvent, 3, type: Sass.EmbeddedProtocol.OutboundMessage.LogEvent, oneof: 0

  field :canonicalizeRequest, 4,
    type: Sass.EmbeddedProtocol.OutboundMessage.CanonicalizeRequest,
    oneof: 0

  field :importRequest, 5, type: Sass.EmbeddedProtocol.OutboundMessage.ImportRequest, oneof: 0

  field :fileImportRequest, 6,
    type: Sass.EmbeddedProtocol.OutboundMessage.FileImportRequest,
    oneof: 0

  field :functionCallRequest, 7,
    type: Sass.EmbeddedProtocol.OutboundMessage.FunctionCallRequest,
    oneof: 0

  field :versionResponse, 8, type: Sass.EmbeddedProtocol.OutboundMessage.VersionResponse, oneof: 0
end

defmodule Sass.EmbeddedProtocol.ProtocolError do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          type: Sass.EmbeddedProtocol.ProtocolError.ErrorType.t(),
          id: non_neg_integer,
          message: String.t()
        }

  defstruct [:type, :id, :message]

  field :type, 1, type: Sass.EmbeddedProtocol.ProtocolError.ErrorType, enum: true
  field :id, 2, type: :uint32
  field :message, 3, type: :string
end

defmodule Sass.EmbeddedProtocol.SourceSpan.SourceLocation do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          offset: non_neg_integer,
          line: non_neg_integer,
          column: non_neg_integer
        }

  defstruct [:offset, :line, :column]

  field :offset, 1, type: :uint32
  field :line, 2, type: :uint32
  field :column, 3, type: :uint32
end

defmodule Sass.EmbeddedProtocol.SourceSpan do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          text: String.t(),
          start: Sass.EmbeddedProtocol.SourceSpan.SourceLocation.t() | nil,
          end: Sass.EmbeddedProtocol.SourceSpan.SourceLocation.t() | nil,
          url: String.t(),
          context: String.t()
        }

  defstruct [:text, :start, :end, :url, :context]

  field :text, 1, type: :string
  field :start, 2, type: Sass.EmbeddedProtocol.SourceSpan.SourceLocation
  field :end, 3, type: Sass.EmbeddedProtocol.SourceSpan.SourceLocation
  field :url, 4, type: :string
  field :context, 5, type: :string
end

defmodule Sass.EmbeddedProtocol.Value.String do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          text: String.t(),
          quoted: boolean
        }

  defstruct [:text, :quoted]

  field :text, 1, type: :string
  field :quoted, 2, type: :bool
end

defmodule Sass.EmbeddedProtocol.Value.Number do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: float | :infinity | :negative_infinity | :nan,
          numerators: [String.t()],
          denominators: [String.t()]
        }

  defstruct [:value, :numerators, :denominators]

  field :value, 1, type: :double
  field :numerators, 2, repeated: true, type: :string
  field :denominators, 3, repeated: true, type: :string
end

defmodule Sass.EmbeddedProtocol.Value.RgbColor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          red: non_neg_integer,
          green: non_neg_integer,
          blue: non_neg_integer,
          alpha: float | :infinity | :negative_infinity | :nan
        }

  defstruct [:red, :green, :blue, :alpha]

  field :red, 1, type: :uint32
  field :green, 2, type: :uint32
  field :blue, 3, type: :uint32
  field :alpha, 4, type: :double
end

defmodule Sass.EmbeddedProtocol.Value.HslColor do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          hue: float | :infinity | :negative_infinity | :nan,
          saturation: float | :infinity | :negative_infinity | :nan,
          lightness: float | :infinity | :negative_infinity | :nan,
          alpha: float | :infinity | :negative_infinity | :nan
        }

  defstruct [:hue, :saturation, :lightness, :alpha]

  field :hue, 1, type: :double
  field :saturation, 2, type: :double
  field :lightness, 3, type: :double
  field :alpha, 4, type: :double
end

defmodule Sass.EmbeddedProtocol.Value.List do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          separator: Sass.EmbeddedProtocol.Value.List.Separator.t(),
          has_brackets: boolean,
          contents: [Sass.EmbeddedProtocol.Value.t()]
        }

  defstruct [:separator, :has_brackets, :contents]

  field :separator, 1, type: Sass.EmbeddedProtocol.Value.List.Separator, enum: true
  field :has_brackets, 2, type: :bool
  field :contents, 3, repeated: true, type: Sass.EmbeddedProtocol.Value
end

defmodule Sass.EmbeddedProtocol.Value.Map.Entry do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          key: Sass.EmbeddedProtocol.Value.t() | nil,
          value: Sass.EmbeddedProtocol.Value.t() | nil
        }

  defstruct [:key, :value]

  field :key, 1, type: Sass.EmbeddedProtocol.Value
  field :value, 2, type: Sass.EmbeddedProtocol.Value
end

defmodule Sass.EmbeddedProtocol.Value.Map do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          entries: [Sass.EmbeddedProtocol.Value.Map.Entry.t()]
        }

  defstruct [:entries]

  field :entries, 1, repeated: true, type: Sass.EmbeddedProtocol.Value.Map.Entry
end

defmodule Sass.EmbeddedProtocol.Value.CompilerFunction do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer
        }

  defstruct [:id]

  field :id, 1, type: :uint32
end

defmodule Sass.EmbeddedProtocol.Value.HostFunction do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          signature: String.t()
        }

  defstruct [:id, :signature]

  field :id, 1, type: :uint32
  field :signature, 2, type: :string
end

defmodule Sass.EmbeddedProtocol.Value do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          value: {atom, any}
        }

  defstruct [:value]

  oneof :value, 0
  field :string, 1, type: Sass.EmbeddedProtocol.Value.String, oneof: 0
  field :number, 2, type: Sass.EmbeddedProtocol.Value.Number, oneof: 0
  field :rgb_color, 3, type: Sass.EmbeddedProtocol.Value.RgbColor, oneof: 0
  field :hsl_color, 4, type: Sass.EmbeddedProtocol.Value.HslColor, oneof: 0
  field :list, 5, type: Sass.EmbeddedProtocol.Value.List, oneof: 0
  field :map, 6, type: Sass.EmbeddedProtocol.Value.Map, oneof: 0
  field :singleton, 7, type: Sass.EmbeddedProtocol.Value.Singleton, enum: true, oneof: 0
  field :compiler_function, 8, type: Sass.EmbeddedProtocol.Value.CompilerFunction, oneof: 0
  field :host_function, 9, type: Sass.EmbeddedProtocol.Value.HostFunction, oneof: 0
end
