require "test_helper"

class ActsAsAlertableTest < ActiveSupport::TestCase
  def test_tasks_act_as_alertable
    assert Task.respond_to? :raises_alert
    assert_equal Task.alerts_table_name, :alerts
    task = Task.new
    [:alerts, :unresolved_alerts, :has_unresolved_alerts?, :scan_for_alerts!].each do |instance_method_name|
      assert task.respond_to? instance_method_name
    end
  end

  def test_can_use_a_different_table_name
    assert TaskList.respond_to? :raises_alert
    assert_equal TaskList.alerts_table_name, :special_alerts
    list = TaskList.create(title: "my list")
    SpecialAlert.create(alertable_id: list.id, alertable_type: "TaskList", message: "My alert")
    assert list.reload.has_unresolved_alerts?
  end

  def test_tasks_raise_alert_when_past_due_date
    assert_includes(Task.alert_kinds, :past_due)
    task = Task.create(title: "My task", done: false, due_date: Date.current - 5.day)
    assert_not task.has_unresolved_alerts?
    assert_nil task.past_due_alert
    task.scan_for_alerts!
    assert task.has_unresolved_alerts?
    assert_not task.past_due_alert.resolved

    task.update(done: true)
    task.scan_for_alerts!
    task.reload
    assert_not task.has_unresolved_alerts?
    assert task.past_due_alert.resolved
  end
end
