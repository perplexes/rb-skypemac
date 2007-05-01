require 'rubygems'
require 'appscript'
include Appscript

module SkypeMac  

  # Singleton for interfacing with Skype
	class Skype
	  @@groups = nil

    # Initiates a Skype call
	  def Skype.call(*person)
      Call.new person
    end
    
    # The Appscript interface to Skype.  Requires a Hash containing:
    # (1) <i>:command</i> - the Skype API command to pass,
    # (2) <i>:script_name</i> - unknown all though an empty String makes Skype happy.
    # Impl adds <i>:script_name</i> to Hash and warns if it is not provided
    def Skype.send_(params)
      params[:script_name] = "" if not params.has_key? :script_name 
      app('Skype').send_ params
    end
    
    # Returns an Array of Groups
    def Skype.groups
      if not @@groups
        @@groups = Group.groups
      end
      @@groups
    end
    
    # Returns Array of all users in Group.  Accepts types as defined by Group.types
    def Skype.find_users_of_type(group_type)
      Skype.groups.find { |g| g.gtype == group_type}.users
    end

    # Returns an array of users online friends as User objects
    def Skype.online_friends
      Skype.find_users_of_type "ONLINE_FRIENDS"
    end
    
    # Array of all Users that are friends of the current user
    def Skype.all_friends
      Skype.find_users_of_type "ALL_FRIENDS"
    end
    
    # Array of all Users defined as Skype Out users
    def Skype.skypeout_friends
      Skype.find_users_of_type "SKYPEOUT_FRIENDS"
    end
    
    # Array of all Users that the user knows
    def Skype.all_users
      Skype.find_users_of_type "ALL_USERS"
    end
    
    # Array of Users recently contacted by the user, friends or not
    def Skype.recently_contacted_users
      Skype.find_users_of_type "RECENTLY_CONTACTED_USERS"
    end
    
    # Array of Users waiting for authorization
    def Skype.users_waiting_for_authorization
      Skype.find_users_of_type "USERS_WAITING_MY_AUTHORIZATION"
    end
    
    # Array of Users blocked
    def Skype.blocked_users
      Skype.find_users_of_type "USERS_BLOCKED_BY_ME"
    end
    
    # Returns the id of the call if there is an incoming Skype call otherwise nil
    def Skype.incoming_call?
      Call.delete_inactive_calls
      r = Skype.send_ :command => "SEARCH ACTIVECALLS"
      active_call_ids = r.gsub(/CALLS /, "").split(", ")
      active_call_ids.each do |call_id|
        if not Call.self_initd_calls.find { |c| call.call_id == call_id }
          return call_id if call_id != "COMMAND_PENDING"
        end
      end
      return nil
    end
    
    # Returns the Call object for the connected call
    def Skype.answer_call
      incoming_call_id = Skype.incoming_call?
      Call.from_id incoming_call_id if incoming_call_id
    end
  end
end