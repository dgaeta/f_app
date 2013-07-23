class AddFirstPaymentDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_payment_date, :integer
  end
end
