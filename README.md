# SimonSays!

![SimonSays
Logo](https://raw.githubusercontent.com/SimplyBuilt/SimonSays/master/SimonSays.png)

This gem is a simple, declarative, role-based access control system for
Rails that works great with devise!

[![Travis Build Status](https://travis-ci.org/SimplyBuilt/SimonSays.svg)](https://travis-ci.org/SimplyBuilt/SimonSays)
[![Gem Version](https://badge.fury.io/rb/simon_says.svg)](https://badge.fury.io/rb/simon_says)
[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

### Installation

SimonSays can be installed via your Gemfile or using Ruby gems directly.

```ruby
gem 'simon_says'
```

### Usage

SimonSays consists of two parts:

1. A [Roleable](#roleable) concern which provides a way to define access roles
   on User models or on join through models.
2. An [Authorizer](#authorizer) concern which provides a declarative API
   to controllers for finding and authorizing model resources.

#### Roleable

First, we need to define some roles on a model. Roles are stored as an
integer and [bitmasking](https://en.wikipedia.org/wiki/Mask_(computing))
is used to determine the roles assigned for that model. SimonSays
provides a generator for creating a new migration for this required
attribute:

```bash
rails g active_record:simon_says User
```

Now we can define some roles in our User model. For example:

```ruby
class User < ActiveRecord::Base
  include SimonSays::Roleable

  has_roles :add, :edit, :delete
end

# > User.new.roles
# => []

# > u = User.new(roles: %i[add edit])
#
# > u.roles
# => [:add, :edit]
# > u.has_add?
# => true
# > u.has_delete?
# => false
```

The attribute name can be customized by using the `:as` option as seen
here in the Admin model:

```ruby
class Admin < ActiveRecord::Base
  include SimonSays::Roleable

  has_roles :design, :support, :moderator, as: :access
end

# > Admin.new.access
# => []

# > Admin.new(access: :support).access
# => [:support]
```

Make sure to generate a migration using the correct attribute name if
`:as` is used. For example:

```bash
rails g active_record:simon_says Admin access
```

We can also use `has_roles` to define roles on a join through model
which is used to associate a User with a resource.

```ruby

class Permission < ActiveRecord::Base
  include SimonSays::Roleable

  belongs_to :user
  belongs_to :document

  has_roles :download, :edit, :delete,
end

# > Permission.new(roles: Permission::ROLES).roles
# => [:download, :edit, :delete]
```

It is useful to note the dynamically generated `has_` methods as shown
in the User model as well the `ROLES` constant which is used in the
Permission example. Take a look at the `Roleable`
[source code](https://github.com/SimplyBuilt/SimonSays/blob/master/lib/simon_says/roleable.rb)
to see how features are dynamically generated with `has_roles`.

#### Authorizer

The `Authorizer` concern provides several methods that can be used within
your controllers in a declarative manner.

Please note, certain assumptions are made with `Authorizer`. Building
upon the above User and Admin model examples, `Authorizer` would assume
there is a `current_user` and `current_admin` method. If these models
correspond to devise scopes this would be the case by default.
Additionally there would need to be an `authenticate_user!` and
`authenticate_admin!` methods, which devise provides as well.

Eventually, we would like to see better customization around the
authentication aspects. This library is intended to solve the problem of
authorization and access control. It is not an authentication library.

In general, the `Authorizer` concern provides four core declarative methods
to be used in controllers. All of these methods accept the `:only` and
`:except` options which end up being used in a `before_action` callback.

- `authenticate(scope, opts): Declarative convenience method to setup
  authenticate `before_action`
- `find_resource(resource, opts)`: Declarative method to find a resource
  and assign it to an instance variable
- `authorize_resource(resource, *roles)`: Authorize resource for given
  roles
- `find_and_authorize(resource, *roles)`: Find a resource and then try
  authorize it for the given roles. If successful, the resource is
  assigned to an instance variable

When find resources, the `default_authorization_scope` is used. It can
be customized on a per-controller basis. For example:

```ruby
class ApplicationController < ActionController::Base
  include SimonSays::Authorizer

  self.default_authorization_scope = :current_user
end
```

To authorize resources against a given role, we use either `authorize`
or `find_and_authorize`. For example, consider this
`DocumentsController` which uses an authenticated `User` resource and a
`Permission` through model:

```ruby
class DocumentsController < ApplicationController
  authenticate :user

  find_and_authorize :document, :edit, through: :permissions, only: [:edit, :update]
  find_and_authorize :document, :delete, through: :permissions, only: :destroy
end
```

This controller will find a Document resource and assign it to the
`@document` instance variable. For the `:edit` and `:update` actions,
it'll require a permission with an `:edit` role. For the `:destroy`
method, a permission with the `:delete` role is required. Since the
`:through` option is used, a `@permission` instance variable will also
be created.

The `find_resource` method may raise an `ActiveRecord::RecordNotFound`
exception. The `authorize` method may raise a
`SimonSays::Authorizer::Denied` exception if there is insufficient role
access. As a result, the `find_and_authorize` method may raise either
exception.

We can also use a different authorization scope with the `:from`
option for `find_resource` and `find_and_authorize`. For example:

```ruby
class ReportsController < ApplicationController
  authorize_resource :admin, :support

  find_resource :report, from: :current_admin, except: [:index, :new, :create]
end
```

Please refer to the
[docs](http://www.rubydoc.info/github/SimplyBuilt/SimonSays/SimonSays/Authorizer/ClassMethods)
for more information on the various declarative methods provided by the
`Authorizer`.

## Contributing

1. Fork it ( https://github.com/SimplyBuilt/SimonSays/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
