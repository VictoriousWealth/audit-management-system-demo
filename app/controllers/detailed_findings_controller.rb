class AuditFindings < ApplicationController
  before_action :set_detailed_finding, only: [:show, :edit, :update, :destroy]

  def new
    @item = Item.new
    respond_to do |format|
      format.js   # render new.js.erb with the form (if loading it dynamically)
    end
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      respond_to do |format|
        format.js   # create.js.erb will update the table + close modal
      end
    else
      render partial: "form", locals: { item: @item }, status: :unprocessable_entity
    end
  end

  # DELETE /detailed_findings/1
  def destroy
    @detailed_finding.destroy
    redirect_to detailed_findings_url, notice: 'Detailed finding was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_detailed_finding
      @detailed_finding = DetailedFinding.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def detailed_finding_params
      params.require(:detailed_finding).permit(:description) # Replace with actual attributes.
    end
end