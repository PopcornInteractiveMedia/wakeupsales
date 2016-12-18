class AddCommentsToDeal < ActiveRecord::Migration
  def change
   add_column :deals, :comments, :text
  end
end
