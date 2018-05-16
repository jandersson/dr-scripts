require 'minitest/autorun'
require 'yaml'
require 'ostruct'
load 'test/test_harness.rb'

include Harness

class DRSpells
  def self.active_spells
    {}
  end
end

class TestDRCA < Minitest::Test
  def setup
    load 'common.lic'
    load 'common-arcana.lic'
    load 'events.lic'

    reset_data
    $history.clear
  end

  def test_find_visible_planets_while_indoors
    $history = [
      'You get an ivory telescope inlaid with a ruby-eyed golden dragon from inside your hunting pack.',
      "That's a bit tough to do when you can't see the sky.",
      'You put your telescope in your hunting pack.'
    ]
    seen_planets = DRCA.find_visible_planets(['a planet', 'another planet'])
    assert_empty(seen_planets)
  end

  def test_invoke_with_exact_amount
    $test_data = {
      spells: OpenStruct.new(YAML.load_file('data/base-spells.yaml'))
    }
    $history = [
      'The nestled armband pulses with Lunar energy.  You reach for its center and forge a magical link to it, readying all of its mana for your use.',
      'Roundtime: 1 sec.'
    ]
    run_script_with_proc('common-arcana', DRCA.invoke('armband', nil, 32))
    assert_sends_messages(['invoke my armband 32'])
  end

  def test_ritual_with_skip_retreat
    load 'common-travel.lic'
    $test_data = {
      spells: OpenStruct.new(YAML.load_file('data/base-spells.yaml'))
    }
    spell_data = {
      'abbrev' => 'SPELL',
      'mana' => 1,
      'skip_retreat' => true,
      'before' => [],
      'after' => [],
      'cast_command' => 'cast',
      'focus' => 'staff',
      'worn_focus' => true,
      'ritual' => true
    }
    $history = [
      'Setting your Evasion stance to 100%, your Parry stance to 0%, and your Shield stance to 80%.  You have 12 stance points left.',
      'You feel intense strain as you try to manipulate the mana streams to form this pattern, and you are not certain that you will have enough mental stamina to complete it.',
      " However, if you utilize a ritual focus: That won't affect your current attunement very much.",
      'You spread your hands apart then slowly bring them together, fingers interlocked.',
      'You sling a crystal-inset oaken staff surmounted with a lumpy spleen off from over your shoulder.',
      'You lift your staff toward the sky and will the mana streams to bend into it.',
      'Roundtime: 20 sec.',
      'You sling a crystal-inset oaken staff surmounted with a lumpy spleen over your shoulder.',
      'You gaze towards the heavens seeking their silent guidance.',
      'The mental strain of this pattern is considerably eased by your ritual focus.',
      "At the ritual's peak, your prophetic connection blooms a thousand-fold.  You are alone.  An infinitesimal speck in space and time adrift in an infinite sea of possibility.  The course of your past, present and future are dictated by ceaseless currents beyond any mortal control."
    ]
    run_script_with_proc('common-arcana', DRCA.ritual(spell_data, []))
    assert_sends_messages(['stance set 100 0 80', 'prepare SPELL 1', 'remove my staff', 'invoke my staff', 'wear my staff', 'cast'])
  end
end
