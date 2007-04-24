require 'rubygems'
require 'appscript'
include Appscript

module SkypeMac  

  # Represents Skype internal grouping of contacts; https://developer.skype.com/Docs/ApiDoc/GROUP_object
  class User
    def User.skype_attr_reader(*attr_sym)
      attr_sym.each do |a|
        module_eval %{def #{a.to_s}
          r = Skype.send_ :command => "get user \#{@handle} #{a.to_s}"
          r.sub(/^.*#{a.to_s.upcase} /, "")
        end}
      end
    end

    attr_reader :handle
    skype_attr_reader :fullname, :birthday, :sex, :language, :country, :province
    skype_attr_reader :city, :phone_home, :phone_office, :phone_mobile, :homepage
    skype_attr_reader :about, :is_video_capable, :buddy_status, :is_authorized
    skype_attr_reader :is_blocked, :onlinestatus, :skypeout, :lastonlinetimestamp
    skype_attr_reader :can_leave_vm, :speeddial, :receivedauthrequest, :mood_text
    skype_attr_reader :rich_mood_text, :is_cf_active, :nrof_authed_buddies
    
    #TODO: attr_reader :aliases, :timezone
    
    attr_accessor :buddystatus, :isblocked, :isauthorized, :speeddial, :displayname



    def initialize(handle)
      @handle = handle
    end
  end
end