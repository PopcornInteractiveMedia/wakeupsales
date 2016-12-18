class BetaAccount < ActiveRecord::Base
  require 'digest'
  attr_accessible :email, :invited_by, :is_approved, :is_registered, :is_verified, :invitation_token, :is_siteadmin_invited
  
  
  ##encrypt email before create
  before_create :generate_invitation_token
  
  
  private
  
  def generate_invitation_token
    self.invitation_token = Digest::MD5.hexdigest "#{self.email}-#{DateTime.now.to_s}"
    #"f71271006593017f9aedcb9aee611154"
  end
  
end
