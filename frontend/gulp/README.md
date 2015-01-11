
You can execute tasks using `gulp {taskName}`

## Major Tasks
  * `default`: This task is executed if you not define the `taskName`.
  * `watch`  : Watch files changes and execute some callback.
  * `dev`    : Start development process, it will execute the `default` task and the `watch` task.
  * `release`: Start release process (production version of your code), it will execute `default` task and release tasks.
  * `test`   : Run and watch tests (you can also use `spec`, `watchTests` and `debugTests`).


## Details of the Major Tasks

* `default`:
  + `setup`    : It will import all file paths from `paths.json`
  + `cleanDev` : It will delete `dev` folder.
  + `install`  : It will prune and install all dependencies.
  + `buildVendorsSASS`    : It will build `vendors.sass` located on `vendors` folder
  + `buildVendorsStyles`  : It will concat vendors css files and the build from `buildVendorsSASS` to `builds/dev/styles`
  + `buildVendorsScripts` : It will copy js files located on `vendors` folder and on `bower_components` to `builds/dev/libs`
  + `buildAppStyles`      : It will build `app.sass` located on `src/main/styles`
  + `buildAppScripts`     : It will compile CoffeeScript files to `builds/dev/scripts`
  + `buildMarkup`         : It will copy html files to `builds/dev/views`
  + `copyResourcesToDevFolder` : It will copy every single file inside `resources` folder to `builds/dev/resources` 
  + `copyImgToDevFolder`       : It will copy every single file inside an `img` folder to `builds/dev/img`
  + `copyIndexToDevFolder'`    : It will process include sources on `index.html` and copy index from `src/main` to `builds/dev`
  + `runDevTests`              : It will run all tests and update the covarage report located on `src/main/specs/coverage`

* `watch`  : 
  + Changes on `SASS (*.sass)` 
  + Changes on `CoffeeScript (*.coffee)`
  + Changes on `index.html`
  + Changes on `resources` folder
  + Changes on `img` folders
 
* `dev`    :  it will execute the `default` task and the `watch` task.

* `release` : it will execute `default` task and...
  + `cleanRelease`      : It will delete `builds/release` folder
  + `proccessIndexFile` : It will use `usemin` and concat and minify all js and css files
  + `copyMarkupToReleaseFolder`   : It will copy all html files to `builds/release/views` folder
  + `minifyMarkupInReleaseFolder` : It will minify all html files
  + `copyCssToReleaseFolder`      : It will copy all css files from `builds/dev/styles` to `builds/release/styles`
  + `copyImgToReleaseFolder`      : It will copy all img files from `builds/dev/img` to `builds/release/img`
  + `optimizeImgInReleaseFolder`  : It will minify images
  + `copyResourcesToReleaseFolder`: It will copy all resources from `builds/dev/resources` to `builds/release/resources`
