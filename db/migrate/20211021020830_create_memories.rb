class CreateMemories < ActiveRecord::Migration[6.1]
  def change
    create_table :memories do |t|
      t.string :user_id
      t.string :uri
      t.string :status, default: "retrieved"
      t.string :text, default: "Tweet preview is unavailable at the moment."
      t.string :date, default: "--"

      t.timestamps
    end
  end
end
