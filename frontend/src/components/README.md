# English

## Components
Web components that you can reuse in other projects

## Structure
As good point of this scaffolding, we can organize almost everything as we wish. Cause everything is mapped by a recursive strategy.

### Required Structure

```
  component
    |-- specs/
    |-- img/
  ```
* `specs`  : We want to create a modular scaffolding, so make sense to bring every single test to our context (inside the component's folder).
But we have to separate app scripts from spec scripts and this way we decided to create the `specs` directory. Everything inside
this diretory will be ignored by Concat and minification gulp tasks to dev and release versions of the project.

* `images` : When we talk about images, we talk about many extensions and is so hard to map every single one. 
So we decided to get everything inside every `img` directory, this way, you must create an `img` directory inside the component's folder to component's images.

### Official Structure
The components folder was based on Angular's concepts cause is so much easier to search something later, so we have:
 ```
  * Directives
  * Filters
  * Factories
  * Services
  * Providers
```

Inside a component folder, it seens like a feature folder:
```
component
  |-- scripts/
  |-- styles/
  |-- specs/
  |-- views/
  |-- img/
```
* `scripts`  : CoffeeScript Files (*.coffee) `This will support js files soon`
* `styles`   : SASS files (*.sass or *.scss) `This will support css files soon`
* `specs`    : CoffeeScript Test Files (*.coffee) based on `jasmine` and will be run by `Karma`
* `views`    : HTML files (*.html)
* `img`      : All images (*.*)

---

* `_components.sass` : That's a shortcut to import the component's styles to the project, cause our `main/styles/app.sass` will import it.
