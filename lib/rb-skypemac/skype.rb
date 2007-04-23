require 'rubygems'
require 'appscript'
include Appscript

module SkypeMac  

  # Singleton for interfacing with Skype
	class Skype

    # Initiates a Skype call
	  def Skype.call(name_or_num)
      Call.new name_or_num
    end
    
    # The Appscript interface to Skype.  Requires a Hash containing:
    # (1) <i>:command</i> - the Skype API command to pass,
    # (2) <i>:script_name</i> - unknown all though an empty String makes Skype happy.
    # Impl adds <i>:script_name</i> to Hash and warns if it is not provided
    def Skype.send_(params)
      params[:script_name] = "" if not params.has_key? :script_name 
      app('Skype').send_ params
    end
    
    # Returns a hash of symbols => Group objects.  The key is the group type.
    def Skype.groups
      if @@groups.nil?
        @@groups = Groups.get_groups
      end
      @@groups
    end
  end
end