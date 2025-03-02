# typed: strict

module CoreLibrary
  extend T::Sig

  CONTENT_TYPE_HEADER = T.let('content-type'.freeze, String)
  CONTENT_LENGTH_HEADER = T.let('content-length'.freeze, String)
  METHOD = T.let('method'.freeze, String)
  URL = T.let('url'.freeze, String)
  STATUS_CODE = T.let('status_code'.freeze, String)
  REDACTED = T.let('**Redacted**'.freeze, String)
end

