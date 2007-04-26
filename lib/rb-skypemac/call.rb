require 'rubygems'
require 'appscript'
include Appscript


module SkypeMac

  # Represents a Skype call
  class Call
    @@TOGGLE_FLAGS = [:START, :STOP]
  
    attr :id
  
    # Creates and initializes a Skype call.  Accepts the handle of the user to call or a User object
    def initialize(user)
      user = user.handle if user.is_a? User
      status = Skype.send_ :command => "call #{user}"
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
  
    # Returns one of: VIDEO_NONE, VIDEO_SEND_ENABLED, VIDEO_RECV_ENABLED, VIDEO_BOTH_ENABLED
    def get_video_status
      Skype.send_ :command => "get call #{id} video_status"
    end
  
    # Accepts <i>:START</i> or <em>:STOP</em>
    def send_video(toggle_flag)
      raise Error.new("Illegal flag: #{toggle_flag}") if not @@TOGGLE_FLAGS.index toggle_flag
      Skype.send_ :command => "alter call #{id} #{toggle_flag.downcase.to_s}_video_send"
    end
  
    # Accepts <em>:START</em> or <em>:STOP</em>
    def rcv_video(toggle_flag)
      raise Error.new("Illegal flag: #{toggle_flag}") if not @@TOGGLE_FLAGS.index toggle_flag
      Skype.send_ :command => "alter call #{id} #{toggle_flag.downcase.to_s}_video_receive"
    end
  end
end