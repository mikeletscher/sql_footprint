ActiveRecord::Schema.define do
  self.verbose = false

  create_table :widgets, force: true do |t|
    t.string :name
    t.integer :quantity

    t.timestamps
  end

  create_table :cogs, force: true do |t|
    t.string :name
    t.integer :quantity
    t.references :widget

    t.timestamps
  end
end
