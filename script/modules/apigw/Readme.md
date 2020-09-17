# Module for API Gateway with authorizer


## Objective

Create an API Gateway with an authorizer, into which to add on biz API resources and methods.

---

## Module inputs

See variables.tf for details. The inputs are to identify:

* Project & Environment<br>
API deployment should be provisioned in an isolated manner for each (project, environment) combination.

* API name<br>
Basically API represents a business, using which the users can fulfill business transactions. Provide the name that identifies the business.


## Module outputs

See outputs.tf. The output provides the information on:

* User repository<br>
The repository of user identities that are are authenticated and access the API. Currently Cognito User Pool is used.

* Authorizer<br>
The authorizer ID to be plugged into the add-on business API methods, the accesses to which are to be authenticated.

* Ping URLs<br>
The URLs of the resources to run the health check (ping) against. Currently ping with no authentication and authping with authentication are to be provisioned.

---


## User Repository

To control the accesses to API needs an repository to manage identities and a mechanism to authenticate those that access the APIs. A Cognigo User Pool is used to manage users. The decision is made because:

1. There is no available user repository (e.g. MS AD), hence needs a repository.
2. Cognito User Pool is an AWS native service that provides the repository.

If there is an existing user repository, look to only using Cognito Identity Pool to federate with.

---


