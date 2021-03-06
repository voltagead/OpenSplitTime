class Api::V1::EffortsController < ApiController
  before_action :set_effort, except: :create

  def show
    authorize @effort
    @effort.split_times.load.to_a if prepared_params[:include]&.include?('split_times')
    render json: @effort, include: prepared_params[:include], fields: prepared_params[:fields]
  end

  def create
    @effort = Effort.new(permitted_params)
    authorize @effort

    if @effort.save
      render json: @effort, status: :created
    else
      render json: {errors: [jsonapi_error_object(@effort)]}, status: :unprocessable_entity
    end
  end

  def update
    authorize @effort
    if @effort.update(permitted_params)
      render json: @effort
    else
      render json: {errors: [jsonapi_error_object(@effort)]}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @effort
    if @effort.destroy
      render json: @effort
    else
      render json: {errors: [jsonapi_error_object(@effort)]}, status: :unprocessable_entity
    end
  end

  private

  def set_effort
    @effort = Effort.friendly.find(params[:id])
  end
end
