class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :content
      t.belongs_to :notifiable, polymorphic: true
      t.integer :receiver_id
      t.integer :sender_id
      t.boolean :opened

      t.timestamps
    end
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end
end
