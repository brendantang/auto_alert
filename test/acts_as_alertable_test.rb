require "test_helper"

class ActsAsAlertableTest < ActiveSupport::TestCase

  # Declaring a class as alertable

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

  # Raise and dismiss alerts

  def test_use_an_instance_method_to_raise_and_dismiss_alerts
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

  def test_different_conditions_to_raise_and_dismiss_an_alert
    order = Order.create(placed: Date.current - 10.day, shipped: false)
    assert_alert order, kind: :week_old, resolved: false
    order.update(placed: Date.current)  # This should not affect the alert
    assert_alert order, kind: :week_old, resolved: false
    order.update(shipped: true)
    assert_alert order, kind: :week_old, resolved: true
  end

  def test_use_a_lambda_to_raise_an_alert
    task_list = TaskList.create
    assert_alert task_list, kind: :no_tasks
  end

  # Message builders

  def test_build_alert_message_from_a_string
    task = Task.create(title: "f", due_date: Date.current)
    assert_alert task, kind: :short_title
    assert_equal "title is too short", task.short_title_alert.message
  end

  def test_build_alert_message_from_a_lambda
    date = Date.current - 2.week
    task = Task.create(title: "f", due_date: date)
    assert_alert task, kind: :past_due
    assert_equal "was due #{date}", task.past_due_alert.message
  end

  def test_build_alert_message_from_a_method_name
    date = Date.current - 2.week
    order = Order.create(placed: date, shipped: false)
    order.scan_for_alerts!
    assert_equal "order was placed on #{date} but has not been shipped", order.week_old_alert.message
  end

  # Determine whether resolved alerts should be re-raised

  def test_dont_reraise_resolved_alerts_by_default
    task = Task.create(title: "My task", done: false, due_date: Date.current - 5.day)
    assert_alert task, kind: :past_due, resolved: false
    task.update(done: true)
    assert_alert task, kind: :past_due, resolved: true

    # Past due alert should not re-raise even though its trigger condition is met again
    task.update(done: false)
    assert_alert task, kind: :past_due, resolved: true
  end

  def test_allow_resolved_alerts_to_be_reraised
    task_list = TaskList.create
    assert_alert task_list, kind: :no_tasks, resolved: false
    task = Task.create(title: "My task", task_list: task_list)
    assert_alert task_list, kind: :no_tasks, resolved: true
    task.destroy
    assert_alert task_list, kind: :no_tasks, resolved: false
  end

  def test_reraise_condition_can_differ_from_raise_condition
    # Refund problem alert should only initially raised if returned but not refunded
    order = Order.create(placed: Date.current - 5.day, returned: false, refunded: true)
    assert_no_alert order, kind: :refund_problem
    order.update(returned: true, refunded: false)
    assert_alert order, kind: :refund_problem, resolved: false
    order.update(returned: true, refunded: true)
    assert_alert order, kind: :refund_problem, resolved: true

    # This should not re-raise refund problem alert
    order.update(refunded: false)
    assert_alert order, kind: :refund_problem, resolved: true

    # Refund problem alert should only be re-raised if refunded but not returned
    order.update(returned: false, refunded: true)
    assert_alert order, kind: :refund_problem, resolved: false
  end

  private

  def assert_alert(record, kind:, resolved: false)
    record.scan_for_alerts!
    assert_class_acts_as_alert record.send("#{kind}_alert").class
    assert_not record.alerts.where(kind: kind, resolved: resolved).empty?
  end

  def assert_no_alert(record, kind:)
    record.scan_for_alerts!
    assert record.alerts.where(kind: kind).empty?
    assert_nil record.send("#{kind}_alert")
  end
end
