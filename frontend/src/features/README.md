# English

## Features
Entities or features of the project.

## Structure
As a good point of this scaffolding, we can organize almost everything as we wish. Cause everything is mapped by a recursive strategy.

### Required Structure

```
  feature
    |-- specs/
    |-- img/
  ```
* `specs`  : We want to create a modular scaffolding, so make sense to bring every single test to our context (inside the feature's folder).
But we have to separate app scripts from spec scripts and this way we decided to create the `specs` directory. Everything inside
this diretory will be ignored by Concat and minification gulp tasks to dev and release versions of the project.

* `images` : When we talk about images, we talk about many extensions and is so hard to map every single one. 
So we decided to get everything inside every `img` directory, this way, you must create an `img` directory inside the feature's folder to feature's images.

### Official Structure
It seens like a component's folder:

```
feature
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

* `_features.sass` : That's a shortcut to import the _feature's styles to the project, cause our `main/styles/app.sass` will import it.
