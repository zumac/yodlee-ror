class Log
  include Mongoid::Document

  field :ep,  as: :endpoint, type: String
  field :mt,  as: :method, type: String
  field :pm,  as: :params, type: String
  field :rc,  as: :response_code, type: Integer
  field :re,  as: :response, type: String

end
