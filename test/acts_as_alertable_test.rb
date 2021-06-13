require "test_helper"

class ActsAsAlertableTest < ActiveSupport::TestCase
  def test_tasks_act_as_alertable
    task = Task.new
    assert task.respond_to? :alerts
  end
end
