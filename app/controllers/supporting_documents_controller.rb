class SupportingDocumentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_supporting_document, only: [:show]



  def show
    # @supporting_document is already set by the before_action
  end


  def set_supporting_document
    @supporting_document = SupportingDocument.find(params[:id])
  end

  def new
    @audit = Audit.find(params[:audit_id])
    @supporting_document = SupportingDocument.new(audit_id: @audit.id)
  end



  def create
    @supporting_document = SupportingDocument.new(supporting_document_params.merge(user_id: current_user.id))
    @audit = Audit.find(@supporting_document.audit_id)

    # Attach the uploaded file
    if params[:supporting_document][:file]
      @supporting_document.file.attach(params[:supporting_document][:file])
    end

    if @supporting_document.save
      flash.now[:notice] = "Document uploaded successfully"
      redirect_to view_audit_path(@audit.id)
    else
      render :new
    end
  end

  private

  def supporting_document_params
    params.require(:supporting_document).permit(:name, :file, :audit_id, :content)
  end
end
