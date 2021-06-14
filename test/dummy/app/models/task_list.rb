class TaskList < ApplicationRecord
  acts_as_alertable with_table: :special_alerts
end
