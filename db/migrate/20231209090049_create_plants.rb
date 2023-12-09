class CreatePlants < ActiveRecord::Migration[6.1]
  def change
    create_table :plants do |t|
      t.string :name, null: false
      t.date :next_water_day
      t.date :next_fertilizer_day
      t.date :next_replant_day
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
