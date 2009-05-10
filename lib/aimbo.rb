require 'rubygems'
require 'net/toc'

require 'status'
require 'user'

module TOCMonkeypatch
  def names
    @buddies.keys
  end
  
  def buddies
    @buddies.values
  end
end

class Net::TOC::BuddyList
  include TOCMonkeypatch
end

module Net::TOC
  Debug = true
end

class XttBot 
  include Net::TOC

  def initialize(*args)
    @client = Net::TOC.new *args
  end

  attr_accessor :client

  def xtt_loop
    while(true) do
      begin
        @client.connect
        puts "buddy list is #{@client.buddy_list.inspect}"
        @client.wait

      rescue Net::TOC::CommunicationError
        sleep 10 # wait, bitches
        $stderr.puts "Communication Error?"
        @client.disconnect
        @client.connect # reconnect
        
      rescue Errno::EPIPE, Errno::ECONNRESET
        sleep 10
        $stderr.puts "DISCONNECT"
        @client.disconnect
        @client.connect # reconnect

      end
    end
  end
end

class Net::TOC::Client
  attr_reader :last_msg
  def event_loop
    # see if there are any pending messages to send any users.
    Message.transaction do
      messages = Message.find(:all) #, :conditions => ['id > ?', @last_msg.to_i])
      if messages && messages.size > 0
        @last_msg = messages.first.id
        messages.each do |message|
          next unless buddy = buddy_list.buddy_named(message.user.aim_login)
          buddy.send_im message.message_text
        end
      end
			Message.delete_all
    end
    @conn.recv do |msg, val|
      @callbacks[msg].call(val) unless @callbacks[msg].nil?
    end
  end
end

class Aimbo
  
  attr_accessor :client, :xtt
  include IM
  
  def initialize(config)
    @config = config
    @xtt ||= XttBot.new(@config[:username], @config[:password])
    @client = @xtt.client
    @error_notifier ||= setup_error_notification
    @im_notifier ||= setup_im
    @setup_away ||= setup_away
  end
  
  def setup_error_notification
    if @config[:send_errors]
      @client.on_error do |error|
        admin = @client.buddy_list.buddy_named(@config[:admin])
        admin.send_im("Error: #{error}")
      end
    end
  end
  
  def setup_im
    @client.on_im do |message, buddy|
      if message =~ /reload/ and buddy.screen_name == @config[:admin]
        puts "Reloading IM::Response"
        #if defined?(IM)
        #  self.class.send :remove_const, :IM
        #end
        load File.dirname(__FILE__) + "/im/response.rb"
        self.class.send :include, IM
      elsif buddy.screen_name == "aolsystemmsg"
        # do nothing
      else
        IM::Response.new message, buddy
      end
    end
  end
  
  def setup_away
    @users = User.find(:all, :conditions => ['aim_login is not null'])
    @users.each do |user|  
      if pal = client.buddy_list.buddy_named(user.aim_login)
        puts "Watching #{pal.to_s}"
        pal.on_status(:available, :away, :idle, :offline) do
          if user.aim_status != pal.status
            user.update_attribute :aim_status, pal.status.to_s
            # todo: hash the screen name to avoid vulns
            File.open(RAILS_ROOT + "/tmp/buddy.#{user.id}.status.txt", "a") do |f|
              # todo: write xml? LOL
              f.write "{ time:#{Time.now.utc.to_f}, status: '#{pal.status.to_s}' }\n"
            end
          end
        end
      end
    end
  end

end

#/var/www/xtt/releases/20080208021931/vendor/rails/railties/lib/commands/runner.rb:47: 
#/usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:218:in `recv': Connection reset by peer - recvfrom(2) (Errno::ECONNRESET)
#from /usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:529:in `join'
#     from /usr/lib64/ruby/gems/1.8/gems/net-toc-0.2/./net/toc.rb:529:in `wait'
#     from /var/www/xtt/releases/20080208021931/lib/aimbo.rb:91
