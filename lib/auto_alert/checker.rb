module AutoAlert
  class Checker
    attr_reader :kind

    def initialize(alert_kind, raise_condition, dismiss_condition, reraise_condition = false, message_builder)
      @kind = alert_kind
      @raise_condition = normalize_check_condition raise_condition
      @dismiss_condition =
        dismiss_condition ?
          normalize_check_condition(dismiss_condition) :
          ->(a) { not @raise_condition.call(a) }
      @reraise_condition = if !reraise_condition # If nil or false
          nil
        elsif reraise_condition == true
          @raise_condition
        else
          normalize_check_condition reraise_condition
        end
      @message_builder = message_builder
    end

    def check(alertable)
      existing_alert = alertable.send("#{@kind}_alert")

      case [existing_alert, @reraise_condition, existing_alert&.resolved]

      # Check for alert for the first time
      in nil, _, _
        if @raise_condition.call(alertable)
          alertable.alerts.create(kind: @kind, message: message(alertable), resolved: false)
        end

      # Check if alert should be dismissed
      in alert, _, false
        alert.update(resolved: true) if @dismiss_condition.call(alertable)

      # Resolved alert should not be re-raised
      in alert, nil, true
        return

      # Check if resolved alert should be re-raised
      in alert, reraise_condition, true
        if reraise_condition.call(alertable)
          alert.update(message: message(alertable), resolved: false)
        end

      else
        return
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
