class Xtt
  @@config = YAML::load_file(RAILS_ROOT + '/config/xtt.yml').freeze
  
  def self.config
    @@config
  end
  
  def self.aimbot_main_loop
    aimbo = Aimbo.new(
      :username => config['aim_username'],
      :password => config['aim_password'],
      :admin => config['aim_admin'],
      :send_errors => config['aim_send_errors']
    )
    aimbo.xtt.xtt_loop
  end
end