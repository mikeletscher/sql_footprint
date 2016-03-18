ActiveRecord::Schema.define do
  self.verbose = false

  create_table :widgets, :force => true do |t|
    t.string :name
    t.integer :quantity

    t.timestamps
  end
end
