class CreateTaskOutcomes < ActiveRecord::Migration
  def change
    create_table :task_outcomes do |t|
      t.string :name
      t.string :task_out_type
      t.string :task_duration
      t.timestamps
    end
    ta_out = TaskOutcome.create([{:name => 'Call me Tomorrow',:task_out_type => 'Call',:task_duration => '1 Day'},{:name => 'Call me after one month',:task_out_type => 'Call',:task_duration => '1 Month'},{:name => 'Send Pricing chart',:task_out_type => 'Quote',:task_duration => '1 Day'},{:name => 'Send Company Brochure',:task_out_type => 'Documentation',:task_duration => '1 Day'},{:name => 'Voice Message',:task_out_type => 'Call',:task_duration => '1 Day'},{:name => 'Not interested in our service'},{:name => 'Do Not want to outsource'},{:name => 'Others'}])
    #ta_out = TaskOutcome.create([{:name => 'Call me Tomorrow',:task_out_type => 'Follow-up,day'},{:name => 'Call me after one month',:task_out_type => 'Follow-up,month'},{:name => 'Send Pricing chart',:task_out_type => 'Follow-up,day'},{:name => 'Send Company Brochure',:task_out_type => 'Follow-up,day'},{:name => 'Voice Message',:task_out_type => 'Follow-up,day'},{:name => 'Not interested in our service'},{:name => 'Do Not want to outsource'},{:name => 'Others'}])
    #ta_out = TaskOutcome.create([{:task_out_type => 'Call'},{:task_out_type => 'Call'},{:task_out_type => 'Follow-up'},{:name => 'Follow-up'},{:name => 'Follow-up'},{:name => 'Follow-up'},{:name => 'Follow-up'}])
  end
end
