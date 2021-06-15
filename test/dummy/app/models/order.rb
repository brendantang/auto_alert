class Order < ApplicationRecord
  acts_as_alertable

  raises_alert :week_old,
    on: ->(order) { order.placed <= Date.current - 1.week },
    resolve_on: :shipped,
    message: :stale_order_message

  raises_alert :refund_problem,
    on: :returned_but_not_refunded?,
    reraise: :refunded_but_not_returned?,
    resolve_on: :no_refund_problems?

  private

  def stale_order_message
    "order was placed on #{placed} but has not been shipped"
  end

  def returned_but_not_refunded?
    returned and !refunded
  end

  def refunded_but_not_returned?
    refunded and !returned
  end

  def no_refund_problems?
    (returned and refunded) or (!refunded and !returned)
  end
end
