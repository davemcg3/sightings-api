module V1
  class SightingsController < ApplicationController
    before_action :set_sighting, only: [:show, :update, :destroy]

    # GET /sightings
    def index
      scoped = Sighting.all
      search_params.except(:sort, :sort_order).each do |search_term, value|
        scoped = scoped.public_send(search_term, value)
      end
      scoped = scoped.arrangement(search_params[:sort], search_params[:sort_order])
      @sightings = scoped

      render json: @sightings
    rescue ActiveRecord::RecordNotFound
      render json: { 'data': 'Not found' }, status: :not_found
    end

    # GET /sightings/1
    def show
      render json: @sighting
    end

    # POST /sightings
    def create
      @report_params = sighting_params
      infer_params
      @sighting = Sighting.new(@report_params)

      if @sighting.save
        render json: @sighting, status: :created
      else
        render json: @sighting.errors, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { 'data': 'Type not found' }, status: :not_found
    end

    # PATCH/PUT /sightings/1
    def update
      authorize! :update, @sighting
      @report_params = sighting_params
      infer_params
      if @sighting.update(@report_params)
        render json: @sighting
      else
        render json: @sighting.errors, status: :unprocessable_entity
      end
    end

    # DELETE /sightings/1
    def destroy
      authorize! :destroy, @sighting
      @sighting.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sighting
        @sighting = Sighting.find(params[:id])
      end

      def search_params
        @report_params = sighting_params

        if @report_params[:start_date]
          @report_params[:start_date] = Time.zone.parse(@report_params[:start_date]).beginning_of_day
        end

        if @report_params[:end_date]
          @report_params[:end_date] = Time.zone.parse(@report_params[:end_date]).end_of_day
        end

        @report_params[:sort] = :created_at unless @report_params[:sort].present?

        case @report_params[:sort_order]
        when 'desc'
          @report_params[:sort_order] = :desc
        else
          @report_params[:sort_order] = :asc
        end

        @report_params
      end

      # Only allow a trusted parameter "white list" through.
      def sighting_params
        return ActionController::Parameters.new.permit if params.except(:controller, :action).empty?
        params.require(:sighting).permit(:subject, :subtype, :zipcode, :notes, :number_sighted, :start_date, :end_date, :sort, :sort_order)
      end

      def infer_params
        @report_params[:user_id] = current_user.id if current_user

        # lookup subject and subtype if passed in
        translate_param(Subject, :subject, :subject_id)
        translate_param(Subtype, :subtype, :subtype_id)

        # grab the type from the subdomain if it wasn't passed in
        unless @report_params[:subject_id].present?
          if request.subdomains.length > 0
            subjects = Subject.all.pluck(:id, :name)
            subjects.each do |id, subject|
              if request.subdomains.include? subject
                @report_params[:subject_id] = id
                break
              end
            end
          end
        end

        # default type to bear type if no subdomain
        unless @report_params[:subject_id].present?
          # @report_params[:subject_id] = 1
          # TODO: set this to _something_ (0?) to mean _all_ subjects?
        end
      end

      def translate_param(model, input_param_name, output_param_name)
        @report_params[output_param_name] = lookup(model, @report_params[input_param_name]) if @report_params[input_param_name]
        @report_params.delete input_param_name if @report_params[output_param_name]
      end

      def lookup(model, value)
        # TODO: Make value case insensitive & partial lookup
        model.find_by(name: value)&.id
      end
  end
end
