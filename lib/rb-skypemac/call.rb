require 'rubygems'
require 'appscript'
include Appscript


module SkypeMac
  # Represents a Skype call.  Developer is responsible for calling Call#hangup at the end of each call, whether it was placed
  # by the caller or is an answered call.
  class Call
    @@TOGGLE_FLAGS = [:START, :STOP]
    @@calls = []
    
    attr :call_id
  
    def Call.active_call_ids
      r = Skype.send_ :command => "SEARCH ACTIVECALLS"
      r.gsub(/CALLS /, "").split(", ")      
    end

    def Call.active_calls
      Call.active_call_ids.collect { |id| Call.new id unless id == "COMMAND_PENDING"}
    end

    def Call.incoming_calls
      Call.active_calls - @@calls
    end
    
    # Creates a Call object from a call_id.
    def initialize(call_id)
      raise ArgumentError "Cannot pass nil call_id" if call_id.nil?
      @call_id = call_id
      @@calls << self
    end
  
    # Attempts to hang up a call. <b>Note</b>: If Skype hangs while placing the call, this method could hang indefinitely.
    # <u>This method must be called at the end of a call, whether the Skype user answered or placed the call!</u>
    def hangup
      Skype.send_ :command => "set call #{@call_id} status finished"
      @@calls.delete self
    end
  
    # Retrieves the status of the current call.<br>
    # <b>Untested</b>
    def status
      Skype.send_ :command => "get call #{@call_id} status"
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