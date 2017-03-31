class BaseParameters

  def self.permitted
    []
  end

  def self.strong_params(class_name, params)
    params.require(class_name).permit(*permitted)
  end

  def self.api_params(params)
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: permitted)
  end

  def self.sort_fields(params)
    SortParams.sort_fields(params, permitted, {id: :asc})
  end
end
