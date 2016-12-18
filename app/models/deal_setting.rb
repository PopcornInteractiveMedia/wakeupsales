class DealSetting < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  attr_accessible :tabs,:organization,:user
  def incoming?
    self.tabs.split(",").include?("1") ? true : false
  end
  def pipeline?
    self.tabs.split(",").include?("2") ? true : false
  end
  def won?
    self.tabs.split(",").include?("3") ? true : false
  end
  def lost?
    self.tabs.split(",").include?("4") ? true : false
  end
  def not_qualify?
    self.tabs.split(",").include?("5") ? true : false
  end
  def junk?
    self.tabs.split(",").include?("6") ? true : false
  end
  def no_contact?
    self.tabs.split(",").include?("7") ? true : false
  end
  def follow_up_required?
    self.tabs.split(",").include?("8") ? true : false
  end
  def follow_up?
    self.tabs.split(",").include?("9") ? true : false
  end
  def quoted?
    self.tabs.split(",").include?("10") ? true : false
  end
  def meeting_scheduled?
    self.tabs.split(",").include?("11") ? true : false
  end
  def forecasted?
    self.tabs.split(",").include?("12") ? true : false
  end
  def waiting_for_project_requirement?
    self.tabs.split(",").include?("13") ? true : false
  end
  def proposal?
    self.tabs.split(",").include?("14") ? true : false
  end
  def estimate?
    self.tabs.split(",").include?("15") ? true : false
  end
end
