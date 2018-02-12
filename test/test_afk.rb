require 'minitest/autorun'
load 'test/test_harness.rb'

include Harness

class Room
  def self.current
    Map.new
  end
end

class Map
  def id
    1
  end
end

class TestAfk < Minitest::Test
  def setup
    self.dead = false
    self.health = 100
    sent_messages.clear
  end

  def test_departs_if_dead
    skip("Test needs to be updated") 
    expected_messages = ['depart item', 'exit']
    self.dead = true

    run_script('afk')

    Timecop.return

    assert_sends_messages expected_messages
  end

  def test_exits_if_low_health
    skip("Test needs to be updated") 
    expected_messages = ['health', 'avoid all', 'exit']
    self.health = 20

    run_script('afk')

    assert_sends_messages expected_messages
  end
end
