require File.dirname(__FILE__) + '/../spec_helper'

describe User::Mailer do
  include ActionMailer::Quoting
  CHARSET = 'utf-8'

  before do
    @user = mock_model User, :email => 'bob@example.com', :activation_code => 'abc', :code => 'def', :login => 'bob', :password => 'bobforpresident'

    @expected = TMail::Mail.new
    @expected.set_content_type 'text', 'plain', { 'charset' => CHARSET }
    @expected.mime_version = '1.0'
    @expected.from         = Xtt.config['email'].to_s
    @expected.to           = @user.email
  end
  
  it "sends activation email" do
    @expected.subject = "New tt account"
    @expected.body    = read_fixture :activation
    
    User::Mailer.create_activation(@user).encoded.should == @expected.encoded
  end
  
  it "sends forgot_password email" do
    @expected.subject = "[tt] Request to change your password."
    @expected.body    = read_fixture :forgot_password
    
    User::Mailer.create_forgot_password(@user).encoded.should == @expected.encoded
  end
  
  it "sends project_invitation email" do
    @project = mock_model Project, :name => "Example", :to_param => '1'
    @expected.subject = "[tt] You've been invited to the #{@project.name.inspect} project."
    @expected.body    = read_fixture :project_invitation
    
    User::Mailer.create_project_invitation(@project, @user).encoded.should == @expected.encoded
  end
  
  it "sends new_invitation email" do
    @project = mock_model Project, :name => "Example", :to_param => '1'
    @expected.subject = "[tt] You've been invited to the #{@project.name.inspect} project."
    @expected.body    = read_fixture :new_invitation
    
    User::Mailer.create_new_invitation(@project, @user).encoded.should == @expected.encoded
  end
  
  def read_fixture(action)
    returning IO.readlines("#{File.dirname(__FILE__)}/../fixtures/mailers/user_mailer/#{action}").join do |data|
      data.gsub! /:host/, Xtt.config['host']
    end
  end
end