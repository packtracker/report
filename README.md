## Automated stat reporting for [packtracker.io](https://packtracker.io/?utm_source=github&utm_medium=action&utm_campaign=links)

Strategies to report your build stats via the following platforms

 - [GitHub Actions](#github-action)
 - [CircleCI Orbs](#cirlceci-orb)

### CircleCI Orb

> In order to use the CircleCI Orb, you must first opt-in your organization to allow third party orbs within your Organization Security settings.
>
> You can do this by going to *Settings* > *Organization* > *Security*

#### Setup

Next, you will add our orb to your configuration by declaring it in your CircleCI configuration.

```yaml
version: 2.1

orbs:
  packtracker: packtracker/report@2.3.0
```

> **Note:** If you started using CircleCI prior to 2.1, you must enable pipelines within your project configuration to be able to use the orbs configuration.

#### Authentication

In order for us to know what project you are reporting stats for, you must send along your packtracker project token.  To do this with the CircleCI Orb, you must create a new project environment variable in your CircleCI settings called `PT_PROJECT_TOKEN`.  You can find your packtracker project token in your project's settings.


#### Configuration

> If you are not yet using [CircleCI Workflows](https://circleci.com/docs/2.0/workflows/), you will need to do so.  If this is the case, you likely have a single build job in your CircleCI configuration.  In order to add the packtracker job to your CI run, you will need to set up a [multi-job workflow as seen in this example configuration](https://circleci.com/docs/2.0/workflows/#workflows-configuration-examples).

Now that you've declared our orb for use and added your project token, you have access to our
`report` **job**.  You can put this job anywhere inside your existing CircleCI workflows.

```yml
workflows:
  version: 2
  your_existing_workflow:
    jobs:
      - build
      - packtracker/report
```

Or, create a new workflow to run packtracker reporting in parallel.

```yml
workflows:
  version: 2
  your_existing_workflow:
    jobs:
      - build
  packtracker:
    jobs:
      - packtracker/report
```

By default, this base configuration should _just work_ most of the time.  If you have a non-standard
setup, you can tweak the job with the following 3 optional parameters.

##### `webpack_config`

We try and assume your webpack configuration is located in the root of your repository as `webpack.config.js`

If it is not, you can let us know where it is like so.

```yaml
workflows:
  packtracker:
    jobs:
      - packtracker/report:
          webpack_config: "./config/webpack/production.js"
```

For example, this is where the Ruby on Rails webpack configuration is located.

##### `project_root`

Sometimes you are trying to track a project within a greater repository, maybe the package.json
does not live at the repository root, but in an internal directory.  This is common for monorepo
configurations like lerna.

```yaml
workflows:
  packtracker:
    jobs:
      - packtracker/report:
          project_root: "./packages/internal_package"
```

##### `selected_resource_class`

Sometimes your Orb might not have enough resources to complete your webpack build, and you might
need to specify a higher resource class.

This is most often surfaced with a nondescript "Killed" message in your build output

> **Note:** [Resource classes are a paid feature of CircleCI](https://circleci.com/docs/2.0/configuration-reference/#resource_class)

```yaml
workflows:
  packtracker:
    jobs:
      - packtracker/report:
          selected_resource_class: medium+
```

### GitHub Action

#### Secrets (Required)

  - `PT_PROJECT_TOKEN` - your [packtracker.io](https://packtracker.io/?utm_source=github&utm_medium=action&utm_campaign=links) project token.

#### Environment variables (Optional)

  - `WEBPACK_CONFIG_PATH` - the relative path to your webpack configuration (if you have one)
  - `PT_PROJECT_ROOT` - the relative path to the directory of your project (containing your package.json file)

#### Workflow

A sample `.github/workflows/push.yml` file might look something like this

```yml
on: push
name: packtracker.io
jobs:
  report:
    name: report webpack stats
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: report webpack stats
      uses: packtracker/report@2.2.9
      env:
        PT_PROJECT_TOKEN: ${{ secrets.PT_PROJECT_TOKEN }}
```
