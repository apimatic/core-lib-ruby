require 'date'
require 'json'
require 'certifi'
require 'apimatic_core_interfaces'
require 'cgi'
require 'json-pointer'

require_relative 'apimatic-core/request_builder'
require_relative 'apimatic-core/response_handler'
require_relative 'apimatic-core/api_call'

require_relative 'apimatic-core/factories/http_response_factory'

require_relative 'apimatic-core/configurations/global_configuration'

require_relative 'apimatic-core/exceptions/invalid_auth_credential'
require_relative 'apimatic-core/exceptions/any_of_validation_exception'
require_relative 'apimatic-core/exceptions/one_of_validation_exception'

require_relative 'apimatic-core/logger/endpoint_logger'

require_relative 'apimatic-core/http/configurations/http_client_configuration'
require_relative 'apimatic-core/http/request/http_request'
require_relative 'apimatic-core/http/response/http_response'
require_relative 'apimatic-core/http/response/api_response'

require_relative 'apimatic-core/types/parameter'
require_relative 'apimatic-core/types/error_case'
require_relative 'apimatic-core/types/sdk/base_model'
require_relative 'apimatic-core/types/sdk/file_wrapper'
require_relative 'apimatic-core/types/sdk/validation_exception'
require_relative 'apimatic-core/types/sdk/api_exception'
require_relative 'apimatic-core/types/xml_attributes'

require_relative 'apimatic-core/types/union_types/leaf_type'
require_relative 'apimatic-core/types/union_types/any_of'
require_relative 'apimatic-core/types/union_types/one_of'
require_relative 'apimatic-core/types/union_types/union_type_context'

require_relative 'apimatic-core/utilities/api_helper'
require_relative 'apimatic-core/utilities/date_time_helper'
require_relative 'apimatic-core/utilities/comparison_helper'
require_relative 'apimatic-core/utilities/file_helper'
require_relative 'apimatic-core/utilities/xml_helper'
require_relative 'apimatic-core/utilities/auth_helper'
require_relative 'apimatic-core/utilities/union_type_helper'

require_relative 'apimatic-core/authentication/header_auth'
require_relative 'apimatic-core/authentication/query_auth'
require_relative 'apimatic-core/authentication/multiple/auth_group'
require_relative 'apimatic-core/authentication/multiple/and_auth_group'
require_relative 'apimatic-core/authentication/multiple/or_auth_group'
require_relative 'apimatic-core/authentication/multiple/single_auth'
