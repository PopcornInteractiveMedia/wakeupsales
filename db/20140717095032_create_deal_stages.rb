class CreateDealStages < ActiveRecord::Migration
  def change
    create_table :deal_stages do |t|
      t.string :name
	  t.integer :original_id
      t.boolean :order_id

      t.timestamps
    end
    
    add_index :deal_stages, :original_id
	execute <<-SQL
     INSERT INTO deal_stages (name,original_id,order_id) values
		('New Deal',1,1),
		('No Contact',7,2),
		('Follow up Required',8,3),
		('Follow up',9,4),
		('Qualified',2,5),
		('Not Qualified',3,6),
		('Quoted',10,7),
		('Meeting Scheduled',11,8),
		('Forecasted',12,9),
		('Won',4,10),
		('Dead',6,11),
		('Lost',5,12),
		('Waiting for Project Requirement',13,13),
		('Proposal',14,14),
		('Estimate',15,15)
	 ; 
	SQL
	execute <<-SQL
	INSERT INTO deal_statuses ( organization_id, name, original_id ) 
	SELECT o.id, ds.name, ds.original_id
	FROM deal_stages ds, organizations o
	WHERE ds.original_id NOT 
	IN (
	SELECT original_id
	FROM deal_statuses dt
	WHERE dt.organization_id = o.id
	)
	;	 
  SQL
	execute <<-SQL
  update `deal_statuses` set name='Dead' where name='Junk' and original_id=6;
  SQL
  end
  
end
