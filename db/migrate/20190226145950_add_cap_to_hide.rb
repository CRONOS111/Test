class AddCapToHide < ActiveRecord::Migration[5.2]
  def change
    add_column :hides, :message_cap, :integer
  end
end
