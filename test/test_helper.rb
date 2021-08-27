# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = "bin/test"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

def assert_class_acts_as_alert(klass)
  record = klass.new
  assert_respond_to record, :alertable
end
  
def assert_alert(record, kind:, resolved: false)
  record.scan_for_alerts!
  assert_class_acts_as_alert record.send("#{kind}_alert").class
  assert_not record.alerts.where(kind: kind, resolved: resolved).empty?
end

def assert_no_alert(record, kind:)
  record.scan_for_alerts!
  assert record.alerts.where(kind: kind).empty?
  assert_nil record.send("#{kind}_alert")
end
