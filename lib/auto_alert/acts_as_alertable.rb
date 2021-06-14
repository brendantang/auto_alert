module AutoAlert
  module ActsAsAlertable
    extend ActiveSupport::Concern

    module ClassMethods
      # Class method to register a model as alertable
      def acts_as_alertable(with_table: :alerts)
        cattr_accessor :alerts_table_name, default: with_table
        alias_attribute :alerts, with_table unless with_table.to_sym == :alerts
        cattr_accessor :alert_checkers, default: []
        has_many with_table.to_sym, as: :alertable, dependent: :destroy
        include AutoAlert::ActsAsAlertable::LocalInstanceMethods
        extend AutoAlert::ActsAsAlertable::SingletonMethods
      end
    end

    module LocalInstanceMethods
      def unresolved_alerts
        alerts.where(resolved: false)
      end

      def has_unresolved_alerts?
        unresolved_alerts.size > 0
      end

      # Check if any alerts should be raised or dismissed
      def scan_for_alerts!
        self.class.alert_checkers.each do |checker|
          checker.check(self)
        end
      end
    end

    module SingletonMethods
      def raises_alert(kind, on:, dismiss_on: nil, message: nil)
        checker = AutoAlert::Checker.new(kind, on, dismiss_on, message)
        alert_checkers << checker
        define_method "#{kind}_alert" do
          alerts.find_by(kind: kind)
        end
      end

      def alert_kinds
        alert_checkers.map do |checker| checker.kind end
      end
    end
  end
end

ActiveRecord::Base.send(:include, AutoAlert::ActsAsAlertable)
