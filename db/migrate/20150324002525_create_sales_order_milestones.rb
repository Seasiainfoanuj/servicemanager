class CreateSalesOrderMilestones < ActiveRecord::Migration
  def change
    create_table :sales_order_milestones do |t|
      t.references :sales_order, index: true
      t.datetime :milestone_date
      t.string :description
      t.boolean :completed
      t.timestamps
    end
  end
end
