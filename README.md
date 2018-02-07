# RbCloak

[![Build Status](https://travis-ci.org/pestanko/RbCloak.svg?branch=master)](https://travis-ci.org/pestanko/RbCloak)

Based on documentation for **Keycloak 3.4**: http://www.keycloak.org/docs-api/3.4/rest-api/index.html


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rb_cloak'
```

And then execute:
```bash
    $ bundle
```
Or install it yourself as:
```bash
    $ gem install rb_cloak
```
## Library Usage
```ruby
client = RbCloak::KeycloakClient.new(url, username: username, password: password)
client.realms.create({realm: 'test_realm'})  # Creates the test realm
client.realms.list # Returns the array of the realms
master = client.realms['master'] # Returns the realms with the name - master

master[:enabled] = true
master.update # Updates the master realm - in this case, it will enable it
client.realms['test_realm'].delete # Deletes the realm
# Clients
master.clients.list # Lists the client that are binded to master realm
master.clients['some_client'] # Reads the client (usign it's name)
master.clients.find_by_name('some_client') # Is same as calling the [] operator
master.clients.read("CLIENT'S UUID") # Reads the client based on the client's UUID
master.clients.find_by_client_id('client_id') # Finds client by it's id
master.clients.find_by(some_attr: value, some_other_attr: value2) # Finds all clients which attribute matches the value
```

## CLI Usage



### Help
```bash
$ bin/rbcloak --help

Usage:
    rbcloak [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    clienttemplates               ClientTemplates management command
    roles                         Roles management command
    clients                       Clients management command
    users                         Users management command
    groups                        Groups management command
    realms                        Realms management command
    login                         Provide login information for the keycloack
    logout                        Logout the keycloack

Options:
    -h, --help                    print help
    -v, --verbose                 be verbose
    --version                     show version
```

### Help for subcommand
```bash
$ bin/rbcloak realms --help

Usage:
    rbcloak realms [OPTIONS] SUBCOMMAND [ARG] ...

  Realms management command

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    list                          List the realm
    create                        Create the realm
    update                        Update the realm
    delete                        Delete the realm
    read                          Read the realm

Options:
    -h, --help                    print help
    -v, --verbose                 be verbose
    --version                     show version

```

### Login and Logout
```bash
$ bin/rbcloak login -u admin -p admin -U 'http://localhost:8080'
$ bin/rbcloak logout
```

### Realm
```bash
bin/rbcloak realms list # Gets the realms list
bin/rbcloak realms read some_realm # Gets the realm's JSON representation
bin/rbcloak realms delete some_realm # Deletes the realm
bin/rbcloak realms update some_realm # Updates the realm (write JSON to STDIN, end it with EOF)
bin/rbcloak realms create # Creates a realm (write JSON to STDIN, end it with EOF)
```

### Client
```bash
bin/rbcloak clients list --realm=master # List clients for the master realm
bin/rbcloak clients secret --realm=master some_client # Gets the client's secret
bin/rbcloak clients read --realm=master some_client # Gets the client JSON representation
bin/rbcloak clients delete --realm=master some_client # Deletes the client
bin/rbcloak clients update --realm=master some_client # Updates the client (write JSON to STDIN, end it with EOF)
bin/rbcloak clients create --realm=master # Creates the client (write JSON to STDIN, end it with EOF)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pestanko/keycloak_admin. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the KeycloakAdmin project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pestanko/keycloak_admin/blob/master/CODE_OF_CONDUCT.md).
