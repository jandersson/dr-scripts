require 'minitest/autorun'
require 'timecop'
load 'test/test_harness.rb'

include Harness

def before_dying(&code)
  Script.at_exit(&code)
end

class Char
  def self.name
    'McTesterson'
  end
end

class CharSettings
  def self.[](_name); end
  def self.[]=(_name, _value);end
end

class XMLData
  def self.game
    'DR'
  end
end

class UpstreamHook
  def self.add(*);end
  def self.remove(*);end
end

class DownstreamHook
  def self.add(*);end
  def self.remove(*);end
end

class TestDrinfomon < Minitest::Test
  def setup
    $history.clear
    sent_messages.clear
  end

  def test_sends_info_on_startup_when_alive
    self.dead = false
    run_script('drinfomon.lic')
    sleep(0.1)
    assert_sends_messages(['exp all', 'info'])
  end

  def test_skips_info_on_startup_when_dead
    self.dead = true
    run_script('drinfomon.lic')
    sleep(0.1)
    assert_sends_messages(['exp all'])
  end

  def test_sends_info_after_departing
    self.dead = true
    run_script('drinfomon.lic')
    sent_messages.clear
    Timecop.scale(60)
    self.dead = false
    sleep(0.1)
    Timecop.return()
    assert_sends_messages(['info'])
  end

  def test_sends_exp_all_after_exp_conversion
    self.dead = false
    $history = ["Name: Navigator Dijkstra Bellman-Ford of Elanthia   Race: Elothean   Guild: Trader",
                'Gender: Male   Age: 31   Circle: 57',
                'Wealth: 0',
                "Log-on system converted 100% of your character's field experience into earned rank."]
    run_script('drinfomon')
    sleep(0.1)
    assert_sends_messages(['exp all', 'info', 'exp all'])
  end
end