#check https://github.com/Diego81/omnicontacts for more info

require "omnicontacts"

Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, "128073895514-dojm7tr6e5rbcfc58pvrpdgn2n4atm03.apps.googleusercontent.com", "SN_1exC69qKJuKXWPYl4CO6A", {:redirect_path => "/contacts/gmail/contact_callback"}

end


