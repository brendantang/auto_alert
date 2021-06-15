module AutoAlert
  class Checker
    attr_reader :kind

    def initialize(alert_kind, raise_condition, dismiss_condition, message_builder)
      @kind = alert_kind
      @raise_condition = normalize_check_condition raise_condition
      @dismiss_condition =
        dismiss_condition ?
          normalize_check_condition(dismiss_condition) :
          ->(a) { not @raise_condition.call(a) }
      @message_builder = message_builder
    end

    def check(alertable)
      existing_alert = alertable.send("#{@kind}_alert")

      # Don't re-raise alerts that have already resolved.
      return if existing_alert&.resolved

      if existing_alert && @dismiss_condition.call(alertable)
        # Dismiss existing alert
        existing_alert.update(resolved: true)
      elsif existing_alert
        # Update message if alert still applies
        existing_alert.update(message: message(alertable))
      elsif @raise_condition.call(alertable)
        # Raise alert for the first time
        alertable.alerts.create(kind: @kind, message: message(alertable), resolved: false)
      end
    end

    def message(alertable)
      if @message_builder.respond_to?(:call)
        @message_builder.call(alertable)
      elsif alertable.methods.include?(@message_builder)
        alertable.send(@message_builder)
      else
        @message_builder
      end
    end

    private

    def normalize_check_condition(condition)
      if condition.respond_to?(:call)
        condition
      else
        lambda do |record|
          record.send(condition)
        end
      end
    end
  end
end
