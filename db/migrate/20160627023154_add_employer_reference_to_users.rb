class AddEmployerReferenceToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :employer, index: true
  end
end
