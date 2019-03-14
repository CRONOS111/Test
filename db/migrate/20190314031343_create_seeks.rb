class CreateSeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :seeks do |t|
      t.integer :messize
      t.boolean :enc

      t.timestamps
    end
  end
end
