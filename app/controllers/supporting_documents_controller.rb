
# Controller for handling supporting documents attached to audits.
#
# Provides actions for uploading, viewing, and creating supporting documents
# tied to a specific audit. Access is restricted to authenticated users.
#
# Before actions:
# - authenticate_user!: ensures only logged-in users can access actions
# - set_supporting_document: loads a document for the `show` action
class SupportingDocumentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_supporting_document, only: [:show]

  # Displays a specific supporting document.
  #
  # The document is retrieved by `set_supporting_document` before this action runs.
  #
  # @return [void] renders the `show` view
  def show
    # Already set by the before_action
  end

  # Finds and sets the supporting document based on the `id` parameter.
  #
  # @return [void]
  def set_supporting_document
    @supporting_document = SupportingDocument.find(params[:id])
  end

  # Initialises a new supporting document for a given audit.
  #
  # Loads the audit specified by `params[:audit_id]` and sets it for use in the form.
  #
  # @return [void] renders the `new` view

  def new
    @audit = Audit.find(params[:audit_id])
    @supporting_document = SupportingDocument.new(audit_id: @audit.id)
  end

  # Creates a new supporting document and attaches an uploaded file.
  #
  # Associates the document with the current user and an audit.
  # If a file is included, it is attached to the document. On success, redirects
  # to the audit view page; otherwise, re-renders the `new` form.
  #
  # @return [void] redirects or re-renders the form depending on success
  def create
    @supporting_document = SupportingDocument.new(supporting_document_params.merge(user_id: current_user.id))
    @audit = Audit.find(@supporting_document.audit_id)

    # Attach the uploaded file
    if params[:supporting_document][:file]
      @supporting_document.file.attach(params[:supporting_document][:file])
    end

    #Save the file and redirect the user
    if @supporting_document.save
      flash.now[:notice] = "Document uploaded successfully"
      redirect_to view_audit_path(@audit.id)
    else
      flash.now[:notice] = "Document upload failed"
      render :new
    end
  end

  private

  # Parameters for creating a supporting document.
  #
  # @return [ActionController::Parameters] the permitted parameters
  def supporting_document_params
    params.require(:supporting_document).permit(:name, :file, :audit_id, :content)
  end
end
