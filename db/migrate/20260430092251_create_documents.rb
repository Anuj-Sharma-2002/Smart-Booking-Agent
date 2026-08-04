class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.text :content

      t.timestamps
    end

    execute <<~SQL
      ALTER TABLE documents
      ADD COLUMN embedding vector(768);
    SQL
  end
end
