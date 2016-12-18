class CreateFeedKeywords < ActiveRecord::Migration
  def change
    create_table :feed_keywords do |t|
      t.references :organization
      t.string :feed_tags

      t.timestamps
    end
    add_index :feed_keywords, :organization_id
  end
end
