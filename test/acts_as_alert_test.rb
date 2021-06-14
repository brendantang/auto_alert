require "test_helper"

class ActsAsAlertTest < ActiveSupport::TestCase
  def test_alert_acts_as_alert
    assert_class_acts_as_alert(Alert)

  end

  def test_special_alert_acts_as_alert
    assert_class_acts_as_alert(SpecialAlert)
  end

  def only_allow_one_alert_per_record_per_kind
    flunk
  end

  private

  def assert_class_acts_as_alert(klass)
    flunk
  end
end
