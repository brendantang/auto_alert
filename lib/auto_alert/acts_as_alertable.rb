module AutoAlert
  module ActsAsAlertable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_alertable
        has_many :alerts, as: :alertable, dependent: :destroy
      end
    end
  end
end

ActiveRecord::Base.send(:include, AutoAlert::ActsAsAlertable)
