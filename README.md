# ExDocDash

Creates API documentation for Elxir projects in the [Docsets format](http://kapeli.com/docsets) for use in Dash.app for  [MacOS X](http://kapeli.com/dash) or [iOS](http://kapeli.com/dash_ios). This is the first draft so problems may occur.

Template Design is generated using Fez Vrasta's [Bootstap Material Design]( http://fezvrasta.github.io/bootstrap-material-design/) framework

## Installation & Usage

*Please note that you will need to have the `sqlite3` binary installed.*

### As a dependency for your project

Open up your `mix.exs` and add the following to your deps.

    {:ex_doc_dash, "~> 0.2.0", only: :docs}

Build your dependencies

    MIX_ENV=docs mix do deps.get, deps.compile

Now you can build your Dash.app documentation using the `docs.dash` task and it will be save in `./docs`.

    MIX_ENV=docs mix docs.dash

### As a global archive

Check out ExDocDash and install as a global dependency

    git clone https://github.com/JonGretar/ExDocDash.git
    cd ExDocDash
    mix do archive.build, archive.install

Now you should have the `docs.dash` mix task available in all projects.

**Note that these projects will have to have `ex_doc` and `earmark` as it's dependency as it's not globally installed.**

## Example of generating [Phoenix](https://github.com/phoenixframework/phoenix) Documentation

![ExDocDash Phoenix docs](https://us-east.manta.joyent.com/JonGretar/public/ExDocDash-Phoenix-1.gif)


## Contributing

All contributions are appreciated. Info on the Docset format can be found in the following links.

 * http://kapeli.com/docsets
 * http://kapeli.com/dash_guide
 * https://github.com/Kapeli/Dash-User-Contributions
