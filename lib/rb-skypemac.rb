Dir[File.join(File.dirname(__FILE__), 'rb-skypemac/**/*.rb')].sort.each { |lib| require lib }

require 'rubygems'
require 'appscript'
include Appscript

module SkypeMac  
  # Singleton for interfacing with Skype
	class Skype
	  def Skype.call(name_or_num)
      Call.new name_or_num
    end
    
    # The Appscript interface to Skype.  Requires a Hash containing:
    # <li><i>:command</i> - the <a href="https://developer.skype.com/Docs/ApiDoc">Skype API command to pass</a>
    # <li><i>:script_name</i> - unknown all though an empty String makes Skype happy
    # Impl adds :script_name to Hash and warns if it is not provided
    def Skype.send_(params)
      if not params.has_key? :script_name and not @suppress_warnings
        puts "Warning: Skype Applescript API require 'script_name' key (even with an empty String value).  Adding..."
        params[:script_name] = ""
      end
      app('Skype').send_ params
    end
    
    def Skype.suppress_warnings
      @suppress_warnings = 1
    end
  end
  
  class Call
    @@TOGGLE_FLAGS = [:START, :STOP]
    
    attr :id
    
    # Creates and initializes a Skype call
    def initialize(name_or_num)
      status = Skype.send_ :command => "call #{name_or_num}"
      if status =~ /CALL (\d+) STATUS/
        @id = $1
      else
        raise Error.new("Could not obtain Call ID")
      end
    end
    
    # Attempts to hang up a call.<br>
    # <b>Note</b>: If Skype hangs while placing the call, this method could hang indefinitely
    def hangup
      Skype.send_ :command => "set call #{@id} status finished"
    end
    
    # Retrieves the status of the current call.<br>
    # <b>Untested</b>
    def status
      Skype.send_ :command => "get call #{@id} status"
    end
    
    # Returns one of:<br>
    # <li>VIDEO_NONE
    # <li>VIDEO_SEND_ENABLED
    # <li>VIDEO_RECV_ENABLED
    # <li>VIDEO_BOTH_ENABLED
    def get_video_status
      Skype.send_ :command => "get call #{id} video_status"
    end
    
    # Accepts :START or :STOP
    def send_video(toggle_flag)
      raise Error.new("Illegal flag: #{toggle_flag}") if not @@TOGGLE_FLAGS.index toggle_flag
      Skype.send_ :command => "alter call #{id} #{toggle_flag.downcase.to_s}_video_send"
    end
    
    # Accepts :START or :STOP
    def rcv_video(toggle_flag)
      raise Error.new("Illegal flag: #{toggle_flag}") if not @@TOGGLE_FLAGS.index toggle_flag
      Skype.send_ :command => "alter call #{id} #{toggle_flag.downcase.to_s}_video_receive"
    end
  end
  
  # Singleton for managing Skype user status
  class Iam
    @@STATUSES = [:ONLINE, :OFFLINE, :SKYPEME, :AWAY, :NA, :DND, :INVISIBLE]
  
    def Iam.set_user_status(status)
      raise NoMethodError.new("#{status} in #{Iam.to_s}") if not @@STATUSES.index status.upcase.to_sym
      Skype.send_ :command => "SET USERSTATUS #{status}"
    end

    # Handles all of the user status permutations accepted by Skype otherwise Errors.
    # For example, <i>Iam.away</i> is legal.
    def Iam.method_missing(id)
      Iam.set_user_status(id.id2name)
    end    
  end
end