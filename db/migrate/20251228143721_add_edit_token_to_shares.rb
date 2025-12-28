class AddEditTokenToShares < ActiveRecord::Migration[8.1]
  def change
    add_column :shares, :edit_token, :string
  end
end
