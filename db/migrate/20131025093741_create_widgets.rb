class CreateWidgets < ActiveRecord::Migration
  def change

    create_table :widgets do |t|
	  t.references :user
	  t.integer :organization_id
      t.boolean :chart, :default=>true
      t.boolean :activities, :default=>true
      t.boolean :feeds, :default=>true
      t.boolean :tasks , :default=>true
	  t.boolean :usage , :default=>true
	  t.boolean :summary , :default=>true	  
	  
	  t.boolean :pie_chart , :default=>true
	  t.boolean :column_chart , :default=>true
	  
      t.boolean :line_chart , :default=>true
      t.boolean :statistics_chart , :default=>true
	  
      t.timestamps
    end
	
    add_index :widgets, :user_id
	
	Organization.find_each do |org|
		 if org.users.present?
		   org.users.select(:id).each do |usr|
			 Widget.create :organization_id => org.id, :user => usr
			 puts "User created" + usr.id.to_s
		   end
		 end
	   end	  
	   
  end
  
end