# camel-rest-sample

A simple project demonstrating
[Camel REST DSL](http://camel.apache.org/rest-dsl.html) functionality
with [Karaf](http://karaf.apache.org) OSGi container.


# Routing REST with Camel

The main idea is in the routes, see class Routes.

## Add a REST implementation component to Camel context

First select and add a REST implementation component to Camel
context. I've chosen Camel Spark REST for this project. In this case
the configuration is done in the OSGi component activation method:

    camelContext.addComponent("spark-rest", new SparkComponent());
    

## Configuring REST DSL implementation

In the sample the [Camel REST DSL](http://camel.apache.org/rest-dsl.html) server is configured in the method `createRouteBuilder()`:

    restConfiguration("rest-api")
            .component("spark-rest")
            .host("localhost")
            .port(9000)
            .bindingMode(RestBindingMode.json);

The code above configures a component named 'spark-rest' (see previous
section) to serve in localhost, port 9000 and use JSON binding mode
only.


## Configuring REST routes

The actual REST routes are configured below. Here I've kept all routes
together under the single `rest("/api")` call.


### Producing `application/json` from method

For example, getting a list of all users:

    rest("/api")
            .get("/users")
            .id("api-users")
            .produces("application/json")
            .route()
            .bean(users, "listAllUsers")
            .endRest()

The bean returns a Java List of User objects, which is automagically
transformed to JSON by Jackson, which Camel uses by default. The
response HTTP Content-Type header is set using the method
`produces("application/json")`.


### Passing URI parameter to method

The Camel Spark REST puts URI path parameters to message headers. It
would be possible to make a converter to transform that to an actual
message, but in this case it's simpler to use the header directly in
the bean call like this:

            .get("/users/{name}")
            .id("api-user-by-name")
            .produces("application/json")
            .route()
            .bean(users, "getUser(${header.name})")
            .endRest()
            
There the URI `{name}` argument is taken from `${header.name}` and
passed to the method `getUser` as parameter. This helps to keep the
`getUser` API simple and independent from any routing or REST
concerns.


### Passing POST JSON as POJO to method

Finally, we let Camel parse input JSON to User class and pass that to the method `addUser`:

            .post("/users")
            .id("api-new-user")
            .consumes("application/json")
            .type(User.class)
            .route()
            .bean(users, "addUser")
            .endRest()

The REST route consumes `application/json` and the type of the input
is explicitly set to User class. Camel uses Jackson in the background
to parse the use class. The same thing happens with return values, and
type may be given with `typeOut` method call, if required.


# License

See the file LICENSE.
