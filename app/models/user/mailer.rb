class User::Mailer < ActionMailer::Base
  include ActionController::UrlWriter

  def activation(user)
    setup_user(user)
    @subject = "New tt account"
    @body[:url]  = activate_url(:activation_code => user.activation_code, :host => Xtt.config['host'])
  end

  def forgot_password(user)
    setup_user(user)
    @subject = "[tt] Request to change your password."
    @body[:url]  = activate_url(:activation_code => user.activation_code, :host => Xtt.config['host'])
  end
  
  def project_invitation(project, user)
    setup_user(user)
    @subject = "[tt] You've been invited to the #{project.name.inspect} project."
    @body[:project] = project
    @body[:url]     = project_url(:id => project, :host => Xtt.config['host'])
  end
  
  def new_invitation(project, invitation)
    setup_user invitation
    @subject = "[tt] You've been invited to the #{project.name.inspect} project."
    @body[:project] = project
    @body[:url]     = invite_url(:code => invitation.code, :host => Xtt.config['host'])
  end

protected
  def setup_user(user)
    @from        = Xtt.config['email'].to_s
    @recipients  = "#{user.email}"
    @body[:user] = user
  end
end
