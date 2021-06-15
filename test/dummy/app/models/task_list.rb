class TaskList < ApplicationRecord
  has_many :tasks
  acts_as_alertable with_table: :special_alerts
  raises_alert :no_tasks, on: ->(tl) { tl.tasks.empty? }
end
