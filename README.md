# SimonSays!

![SimonSays
Logo](https://raw.githubusercontent.com/SimplyBuilt/SimonSays/master/SimonSays.png)

This gem is a simple, declarative, role-based access control system for Rails that
works great with devise! Take a look at the
[docs](http://simplybuilt.github.io/SimonSays) for more details!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simon_says'
```

Now execute:

    $ bundle

Or install the gem directly via:

    $ gem install simon_says

## Usage

SimonSays consists of two parts. One is a model concern called
`Roleable`. The other is a controller concern called `Authorizer`. The
idea is that you give users some set of roles and find and authorize
resources against those roles on a controller (and action) basis.

### Roleable

First, we need to define some roles. Generally speaking roles will exist on
either "User" models or on relationship models (like a through model linking a
User to another resource).

Here's a quick example:

    class User < ActiveRecord::Base
      include SimonSays::Roleable

      has_roles :add, :edit, :delete
    end

User can now have zero or more roles:

    User.new.roles
    => []

    User.new.tap { |u| u.roles = :add, :edit }.roles
    => [:add, :edit]

Roles are stored as an integer and bitmasking is used to determine
authorization logic. When using `Roleable` you need add a `roles_mask`
column. Note that we do not have any generators for this yet.  Feel
free to fork and add them!

You can customize the role attribute using the `:as` option. For
example:

    class Admin < ActiveRecord::Base
      include SimonSays::Roleable

      has_roles :design, :support, :moderator, as: :access
    end

    Admin.new.access
    => []

    Admin.new(access: :support).access
    => [:support]

The `Roleable` will expect there to be a `access_mask` column and
attribute.

You can also use `Roleable` on through models. For example:

    class Membership < ActiveRecord::Base
      include SimonSays::Roleable

      belongs_to :user
      belongs_to :document

      has_roles :download, :edit, :delete,
    end

Calling `has_roles` will dynamically generate several methods as well as
a dynamically named scope. Be sure to also checkout the
[docs](http://simplybuilt.github.io/SimonSays/SimonSays/Roleable/ClassMethods.html)
for more details!

### Authorizer

Next up is the `Authorizer`. This concern provides several methods that
can be used within your controllers to declaratively find resources and
ensure certain role-based conditions are met.

*Please note*, certain assumptions are made with `Authorizer`. Building
upon the above `User` and `Admin` models, `Authorizer` would assume
there is a `current_user` and `current_admin` method. If these models
correspond to devise scopes this would be the case by default.
Additionally there would need to be an `authenticate_user!` and
`authenticate_admin!` method, which devise provides as well.

Eventually, we would like to see better customization around the
authentication aspects. This library is intended to solve the problem of
authorization and access control. It is not an authentication library.

The first step is to include the concern within the
`ApplicationController` and to configure the default authorization
method:

    class ApplicationController < ActionController::Base
      include SimonSays::Authorizer

      self.default_authorization_scope = :current_user
    end

Let's start with an example; here we'll create a reports resource that
only Admin's with support access to use. The roles are supplied within
the `authorize_resource` method. Note that, multiple roles can be
supplied; access is granted if one or more are met.

    # routes.rb
    # Reports resource for Admins
    resources :reports

    # app/controllers/reports_controller.rb
    class ReportsController < ApplicationController
      authorize_resource :admin, :support
      find_resource :report, except: [:index, :new, :create]
    end

Here's another example using the `Membership` through model and multiple
calls to `find_and_authorize` to setup various role-based requirements.

    # routes.rb
    resources :documents

    # app/controllers/documents_controller.rb
    class DocumentsController < ApplicationController
      authenticate :user

      find_and_authorize :documents, :edit, through: :memberships, only: [:edit, :update]
      find_and_authorize :documents, :delete, through: :memberships, only: :destroy
    end

The document model will not be found if the membership relationship does
not exist and an `ActiveRecord::NotFound` exception will be raised.

If the membership record exists, but the role conditions are not met,
`Authorizer` will raise a `Denied` exception.

If the document is found and the user has the access to it. It will be
set as the `@document` instance variable. Be sure to checkout the
[docs](http://simplybuilt.github.io/SimonSays/SimonSays/Authorizer/ClassMethods.html)
for more details!

## Contributing

1. Fork it ( https://github.com/SimplyBuilt/SimonSays/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
