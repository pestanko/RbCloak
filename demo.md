# RBCLOAK

## Login scenario
```
bin/rbcloak login -u admin -p admin -U 'http://localhost:8080'
bin/rbcloak logout
bin/rbcloak realms list
bin/rbcloak login -u admin -p admin -U 'http://localhost:8080'
bin/rbcloak realms list
```

## Show help
```
bin/rbcloak --help
bin/rbcloak realms --help
```

## Create realm
```
echo '{"realm": "demo"}' | bin/rbcloak realms create
bin/rbcloak realms list
bin/rbcloak realms read demo
bin/rbcloak realms read demo | grep 'enabled'
echo '{"enabled": true}' | bin/rbcloak realms update demo
bin/rbcloak realms read demo | grep 'enabled'
```

### Client in the realm
```
echo '{ "name": "demo_client", "clientId": "demo_client" }' | bin/rbcloak clients create --realm=demo
bin/rbcloak clients list --realm=demo
bin/rbcloak clients read --realm=demo demo_client
bin/rbcloak clients read --realm=demo demo_client | grep 'implicitFlow'
echo '{ "implicitFlowEnabled": true }' | bin/rbcloak clients update --realm=demo demo_client
bin/rbcloak clients read --realm=demo demo_client | grep 'implicitFlow'
bin/rbcloak clients secret --realm=demo demo_client
bin/rbcloak clients delete --realm=demo demo_client
bin/rbcloak clients list --realm=demo
```

### User in the realm
```
echo '{ "username": "demo_user", "email": "user@example.com" }' | bin/rbcloak users create --realm=demo
bin/rbcloak users list --realm=demo
bin/rbcloak users read --realm=demo demo_user
bin/rbcloak users read --realm=demo demo_user | grep 'emailVerified'
echo '{ "emailVerified": true }' | bin/rbcloak users update --realm=demo demo_user
bin/rbcloak users read --realm=demo demo_client | grep 'emailVerified'
bin/rbcloak users secret --realm=demo demo_user
bin/rbcloak users delete --realm=demo demo_user
bin/rbcloak users list --realm=demo
```


### Run the tests
```
bundle exec rake rubocop
bundle exec rake tests
```


### Challenge
* Keycloak - API (create and update do not return entity responses)
* Flows -> Direct access flow vs AuthCodeFlow 
