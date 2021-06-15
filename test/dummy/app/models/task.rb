class Task < ApplicationRecord
  belongs_to :task_list, optional: true

  acts_as_alertable

  raises_alert :past_due,
               on: :past_due_date?,
               message: ->(record) { "was due #{record.due_date}" }


  raises_alert :short_title,
    on: :short_title?,
    dismiss_on: ->(record) { done or !short_title? },
    message: "title is too short"

  private

  def short_title?
    title && title.length < 5
  end

  def past_due_date?
    due_date < Date.current and !done
  end
end
