module AutoAlert
  module ActsAsAlert
    extend ActiveSupport::Concern

    module ClassMethods
      # Class method to register a model as alertable
      def acts_as_alert
        belongs_to :alertable, polymorphic: true
        include AutoAlert::ActsAsAlert::LocalInstanceMethods
        extend AutoAlert::ActsAsAlert::SingletonMethods
      end
    end

    module LocalInstanceMethods
    end

    module SingletonMethods
    end
  end
end

ActiveRecord::Base.send(:include, AutoAlert::ActsAsAlert)
