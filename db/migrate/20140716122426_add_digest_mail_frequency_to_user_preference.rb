class AddDigestMailFrequencyToUserPreference < ActiveRecord::Migration
  def change
    add_column :user_preferences, :digest_mail_frequency, :string, :default => "weekly"
  end
end
