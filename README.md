# auto_alert
[`auto_alert`](https://github.com/brendantang/auto_alert) provides a simple DSL to declare conditions that should raise alerts on your ActiveRecord models.
Alerts are saved in a database table with a [polymorphic association](https://guides.rubyonrails.org/association_basics.html#polymorphic-associations) to the model which triggered their creation.
It's possible to define different conditions to raise, resolve, and re-raise an alert.


## Quick example

Imagine a to-do list application where tasks with a due date in the past should be flagged with an alert.
With `auto_alert`, you can modify your Task model like so:

```ruby
class Task < ApplicationRecord
  acts_as_alertable

  raises_alert :past_due,
               on: :past_due_date?,
               message: "was due"
               
  private
  def past_due_date?
    due_date < Date.current and !done
  end
```

Then you can call the `scan_for_alerts!` on any task and, if `past_due_date?` returns `true`, an alert record belonging to that task will be created.
Instances of `Task` will also have a `past_due_alert` getter method to fetch their associated `past_due` alert, if any.

## Installation
### Install `auto_alert`
Add this line to your application's Gemfile:

```ruby
gem 'auto_alert'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install auto_alert
```

### Create `Alert` model

`auto_alert` assumes there is an `Alert` model to store your alerts in the database.

An appropriate model can be built using the Rails generator by running something like, `rails generate model Alert alertable:polymorphic resolved:boolean kind:string message:string`.
You may want to edit the resulting migration so that it looks like [this example](test/dummy/db/migrate/20210613222049_create_alerts.rb).

Make sure to edit the alert model file to register it with `auto_alert`:

```ruby
# app/models/alert.rb
class Alert < ApplicationRecord
  acts_as_alert # add this line
end
```

(In the future I'd like to add an `install` rake task to automate this process.)

`auto_alert` assumes the alert relation uses the table called `alerts`, but you can specify a different relation:

```ruby
# app/models/task.rb
class Task < ApplicationRecord
  acts_as_alertable # will default to using the Alert model
end

# app/models/task_list.rb
class TaskList < ApplicationRecord
  acts_as_alertable with_table: :special_alerts # will look for a SpecialAlert model
end
```


## Usage

### Scanning for alerts

`auto_alert` makes no assumptions about when you'd like to check if alerts should be raised or resolved.

### Declaring rules to raise, resolve, and re-raise alerts

The `on` parameter to `raises_alert` can take a method name as [above](#quick-example), or a proc:

```ruby
raises_alert :past_due, 
  on: ->(t) { t.due_date < Date.current and !t.done }
```

You can also pass a `resolve_on` parameter to specify the condition for marking the alert `resolved`. 
A proc or method name is acceptable.

```ruby
class Order < ApplicationRecord
  acts_as_alertable

  raises_alert :week_old,
    on: ->(order) { order.placed <= Date.current - 1.week },
    resolve_on: :shipped 
    # Now changing the order date won't resolve the alert, but marking it `shipped` will.
```

### Messages

Alert messages can be built using a string, a proc, or a method name.
When an alert is re-raised, its message will be built again.


### Alert records

`auto_alert` assumes there is an ActiveRecord model for the table `alerts`, with at least:
  - A polymorphic `alertable` reference (pointing to the record which triggered the alert)
  - A boolean `resolved` attribute (indicating the alert is no longer relevant)
  - A `kind` attribute (each alertable record has only one alert of each kind—`past_due` in the example above)
    - Can be a text column or a Rails enumerable using a numeric column ([example](./test/dummy/app/models/special_alert.rb))
  - A string `message` attribute describing the alert details
  
Instructions for creating such a model are in the Installation secion under [Create Alert model](#create-alert-model).




### Dismissing alerts




## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
