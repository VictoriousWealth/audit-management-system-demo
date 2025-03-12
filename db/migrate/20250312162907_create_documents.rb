class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :document_type
      t.datetime :uploaded_at
      t.string :content
      t.string :location

      t.timestamps
    end
  end
end
