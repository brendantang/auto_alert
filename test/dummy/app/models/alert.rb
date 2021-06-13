class Alert < ApplicationRecord
  belongs_to :alertable, polymorphic: true
end
