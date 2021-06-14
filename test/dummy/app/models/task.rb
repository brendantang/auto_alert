class Task < ApplicationRecord
  acts_as_alertable

  raises_alert :past_due, on: :past_due_date?, message: ->(record) do
                            "was due #{record.due_date}"
                          end

  private

  def past_due_date?
    due_date < Date.current and !done
  end
end
