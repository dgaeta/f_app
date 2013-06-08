class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
    	t.integer	:user_id
    	t.text		:date_of_request
    	t.boolean	:deleted, 			:default => "FALSE"

      t.timestamps
    end
  end
end
