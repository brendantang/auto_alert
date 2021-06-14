module AutoAlert
  module ActsAsAlertable
    extend ActiveSupport::Concern

    module ClassMethods
      # Class method to register a model as alertable
      def acts_as_alertable(with_table: :alerts)
        cattr_accessor :alerts_table_name, default: with_table
        has_many with_table.to_sym, as: :alertable, dependent: :destroy
        include AutoAlert::ActsAsAlertable::LocalInstanceMethods
        extend AutoAlert::ActsAsAlertable::SingletonMethods
      end
    end

    module LocalInstanceMethods
      def unresolved_alerts
        send(alerts_table_name).where(resolved: false)
      end

      def has_unresolved_alerts?
        unresolved_alerts.size > 0
      end
    end

    module SingletonMethods
      def raises_alert
      end
    end
  end
end

ActiveRecord::Base.send(:include, AutoAlert::ActsAsAlertable)
