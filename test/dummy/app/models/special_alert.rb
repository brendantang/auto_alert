class SpecialAlert < ApplicationRecord
  acts_as_alert
  enum kind: { no_tasks: 0, duplicate_tasks: 1 }
end
