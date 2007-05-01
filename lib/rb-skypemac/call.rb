require 'rubygems'
require 'appscript'
include Appscript


module SkypeMac

  # Represents a Skype call
  class Call
    @@TOGGLE_FLAGS = [:START, :STOP]
    @@calls = []
    
    attr :call_id
  
    # Good to call as it simply removes Call objects from the cached array of Calls that are no longer in use.
    # Invoked by Skype.incoming_call?
    def Call.delete_inactive_calls
      r = Skype.send_ :command => "SEARCH ACTIVECALLS"
      active_call_ids = r.gsub(/CALLS /, "").split(", ")
      active_calls = []
      # Create an array of active Calls
      active_call_ids.inject(active_calls) do |m, call_id|
        m << @@calls.find { |call| call.call_id == call_id }
      end

      # dead Calls are all Calls that are not active
      dead_calls = @@calls - active_calls

      # Now lose them
      dead_calls.each { |dead_call| @@calls.delete dead_call }
    end
  
    def Call.self_initd_calls
      @@calls
    end
  
    def Call.from_id(id)
      @@calls << call = Call.new(Integer(id))
      call
    end
  
    # Creates and initializes a Skype call.  Accepts a var_arg of handles and/or Users.  Multiple handles/Users
    # should create a conference call.  If args[0] is an Integer, expects to create a Call object from a valid
    # call id (Don't try this at home, folks...)
    def initialize(*args)
      if args[0].is_a? String or args[0].is_a? User
        # Outbound call
        user_str = ""
        user.each { |u| user_str << ((u.is_a? User) ? u.handle : u) }
        status = Skype.send_ :command => "call #{user_str}"
        if status =~ /CALL (\d+) STATUS/: @call_id = $1
        else raise RuntimeError.new("Could not obtain call ID")
        end
      elsif args[0].is_a? Integer
        id_str = args[0].to_s
        # Inbound call - minor kluge with the type check but didn't want to break the existing 0.2.0 API
        status = Skype.send_ :command => "alter call #{id_str} answer"
        if status =~ /ALTER CALL #{id_str} ANSWER/: @call_id = id_str
        else raise RuntimeError.new("Could not answer call: status '#{status}'")
        end
      end
      @@calls << self
    end
  
    # Attempts to hang up a call.<br>
    # <b>Note</b>: If Skype hangs while placing the call, this method could hang indefinitely
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