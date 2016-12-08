Component
=========

The general structure of components is broken down into sections that enable composability and isolation to expedite development and texting.

By convention we expect all components to conform to this scheme in order to ensure that all developers have a shared common understanding when approaching prior art.

These sections are:
- _Bootstrap.js
- Model.elm
- Stub.elm
- Style.elm
- Update.elm
- View.elm

_Bootstrap.js
-------------

This section provides the necessary javascript links to load the Elm component, section, page, etc.

For components, there should be defaulted data sets provided to allow the consumer to init the component into one or more useful states.

For example, in the login form component the consumer can jump directly into a rendered view that allows them to see error states to help with styling of validation messages.

By enforcing the initial context population via the program flags we ensure that the application state is capable of being serialized across the [Elm Ports](http://elm-lang.org:1234/guide/interop) boundary.

You should ensure that the boostrap can be called in isolation at any time without any additional contexted required.

> We may extend the 'run' method to allow the consumer to provide specify the initial data via a switch case from the root app.js file instead of forcing them to edit the _bootstrap.js directly

Model.elm
---------

A component's model is designed to host all data structurs needed to manage and render the compoment.

> Only functions related to data initialization and specialized helpers for data management should be found in this file.

Stub.elm
--------

Style.elm
---------

Update.elm
----------

View.elm
--------
