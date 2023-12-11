class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.datetime :start_time, null: false
      t.boolean :is_watered
      t.boolean :is_fertilized
      t.boolean :is_replanted
      t.text :memo
      t.float :temperature
      t.float :humidity
      t.datetime :light_start_at
      t.datetime :light_end_at
      t.integer :user_id, null: false
      t.integer :plant_id, null: false

      t.timestamps
    end
  end
end
