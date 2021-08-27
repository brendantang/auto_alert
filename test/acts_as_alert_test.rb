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

  def test_scopes
    task = Task.create(title: "my task")
    unresolved = task.alerts.create(kind: "past_due", resolved: false)
    resolved = task.alerts.create(kind: "short_title", resolved: true)
    assert_includes task.alerts.unresolved, unresolved
    assert_includes Alert.unresolved, unresolved
    assert_includes task.alerts.resolved, resolved
    assert_includes Alert.resolved, resolved
    assert_not_includes task.alerts.unresolved, resolved
    assert_not_includes task.alerts.resolved, unresolved
  end

  def test_scan_all_unresolved
    task = Task.create(title: "my ", due_date: Date.current)
    task.scan_for_alerts!
    assert_alert task, kind: :short_title, resolved: false
    task.update(title: "should be long enough now")
    Alert.scan_all_unresolved!
    assert_alert task, kind: :short_title, resolved: true
    
  end

end
