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
    $history = ["Name: Navigator Dijkstra Bellman-Ford of Elanthia   Race: Elothean   Guild: Trader",
                'Gender: Male   Age: 31   Circle: 57',
                'Wealth: 0']
    run_script('drinfomon.lic')
    sleep(0.1)
    assert_sends_messages(['exp all', 'info'])
  end

  def test_skips_info_on_startup_when_dead
    self.dead = true
    $history = ['You are dead']
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
    sleep(0.3)
    Timecop.return()
    assert_sends_messages(['info'])
  end

  def test_drstats_parses_info_correctly
    $history = [
        'Name: Navigator Dijkstra Bellman-Ford of Elanthia   Race: Elothean   Guild: Trader',
        'Gender: Male   Age: 31   Circle: 57',
        'You were born on the 13th day of the 5th month of Uthmor the Giant in the year of the Amber Phoenix, 395 years after the victory of Lanival the Redeemer.',
        'Your birthday is more than 2 months away.',
        '     Strength :  36              Reflex :  33',
        '      Agility :  30 +2         Charisma :  33 +2 ',
        '   Discipline :  32              Wisdom :  32',
        ' Intelligence :  32             Stamina :  36',
        'Concentration : 390    Max : 390',
        '       Favors : 31',
        '         TDPs : 147',
        '  Encumbrance : None',
        '         Luck : Average',
        'Wealth:'
    ]
    self.dead = false
    load 'drinfomon.lic'
    sleep(0.1)
    assert_equal('Trader', DRStats.guild)
    assert_equal('Elothean', DRStats.race)
    assert_equal('Male', DRStats.gender)
    assert_equal(31, DRStats.age)
    assert_equal(57, DRStats.circle)
    assert_equal(36, DRStats.strength)
    assert_equal(33, DRStats.reflex)
    assert_equal(30, DRStats.agility)
    assert_equal(33, DRStats.charisma)
    assert_equal(32, DRStats.discipline)
    assert_equal(32, DRStats.wisdom)
    assert_equal(32, DRStats.intelligence)
    assert_equal(36, DRStats.stamina)
    assert_equal(390, DRStats.concentration)
    assert_equal(31, DRStats.favors)
    assert_equal(147, DRStats.tdps)
    assert_equal('None', DRStats.encumbrance)
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