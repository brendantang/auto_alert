module AutoAlert
  module ActsAsAlert
    extend ActiveSupport::Concern

    module ClassMethods
      # Class method to register a model as alertable
      def acts_as_alert
        belongs_to :alertable, polymorphic: true
        scope :resolved, -> { where(resolved: true) }
        scope :unresolved, -> { where(resolved: false) }

        validates :kind,
          uniqueness: {
            scope: :alertable,
            message: ->(record, data) { "This #{record.alertable_type} already has a '#{data[:value]}' alert." },
          }
        include AutoAlert::ActsAsAlert::LocalInstanceMethods
        extend AutoAlert::ActsAsAlert::SingletonMethods
      end
    end

    module LocalInstanceMethods
    end

    module SingletonMethods
      def scan_all_unresolved!
        unresolved.each { |unresolved_alert| unresolved_alert.alertable.scan_for_alerts! }
      end
    end
  end
end

ActiveRecord::Base.send(:include, AutoAlert::ActsAsAlert)
