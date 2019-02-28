module V1
  class SubtypesController < ApplicationController
    before_action :set_subtype, only: [:show, :update, :destroy]

    # GET /subtypes
    def index
      @subtypes = Subtype.all

      render json: @subtypes
    end

    # GET /subtypes/1
    def show
      render json: @subtype
    end

    # POST /subtypes
    def create
      authorize! :create
      @subtype = Subtype.new(subtype_params)

      if @subtype.save
        render json: @subtype, status: :created
      else
        render json: @subtype.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /subtypes/1
    def update
      authorize! :update
      if @subtype.update(subtype_params)
        render json: @subtype
      else
        render json: @subtype.errors, status: :unprocessable_entity
      end
    end

    # DELETE /subtypes/1
    def destroy
      authorize! :destroy
      @subtype.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_subtype
        @subtype = Subtype.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def subtype_params
        params.require(:subtype).permit(:name, :subject_id, :parent_id)
      end
  end
end
