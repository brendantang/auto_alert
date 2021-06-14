require "test_helper"

class ActsAsAlertTest < ActiveSupport::TestCase
  def test_alert_acts_as_alert
    assert_class_acts_as_alert(Alert)
  end

  def test_special_alert_acts_as_alert
    assert_class_acts_as_alert(SpecialAlert)
  end

  def test_only_allow_one_alert_per_record_per_kind
    task = Task.create(title: "my task")
    task.alerts.create(kind: "past_due")
    duplicate = task.alerts.new(kind: "past_due")
    assert_not duplicate.valid?
    assert_includes duplicate.errors.messages.values, ["This Task already has a 'past_due' alert."]
  end

  private

  def assert_class_acts_as_alert(klass)
    record = klass.new
    assert_respond_to record, :alertable
  end
end
