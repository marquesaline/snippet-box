class CreateShares < ActiveRecord::Migration[8.1]
  def change
    create_table :shares do |t|
      t.string :slug, null: false, index: { unique: true }
      t.text :content
      t.datetime :expires_at
      t.timestamps
    end
  end
end
