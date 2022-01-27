class CreateMemoryTrackers < ActiveRecord::Migration[6.1]
  def change
    create_table :memory_trackers do |t|
      t.string :context
      t.integer :data

      t.timestamps
    end
  end
end
