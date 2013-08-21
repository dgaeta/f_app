class CreateRemarks < ActiveRecord::Migration
  def change
    create_table :remarks do |t|
      t.string :content
      t.string :message
      t.integer :from_user_id
      t.belongs_to :remarkable, polymorphic: true

      t.timestamps
    end
    add_index :remarks, [:remarkable_id, :remarkable_type]

  end
end
