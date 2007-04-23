require File.dirname(__FILE__) + '/test_helper.rb'
include SkypeMac

class TestGroup < Test::Unit::TestCase

  def test_group_types
    gs = Group.types
    assert gs
    assert gs.class == Array
    assert !gs.empty?
  end

  def test_groups
    gs = Group.groups
    assert gs
    assert gs.class == Array
    assert !gs.empty?
  end
  
  def test_get_type
    gs = Group.groups
    type = Group.get_type gs[0].gid
    assert type
    assert type.class == String
    assert type.match(/^\w+$/)
  end
  
  def test_gtype
    gs = Group.groups
    assert gs[0].gtype
    assert gs[0].gtype.class == String
    assert gs[0].gtype.match(/^\w+$/)
  end
  
  def test_gid
    gs = Group.groups
    assert gs[0].gid
    assert gs[0].gid.class == String
    assert gs[0].gid.match(/^\d+$/)
  end
  
  def test_member_user_names
    gs = Group.groups
    user_names = gs[0].member_user_names
    assert user_names
    assert user_names.class == Array
    assert !user_names.empty?
  end
  
  def test_users
  end
end