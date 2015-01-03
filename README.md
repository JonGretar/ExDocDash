# ExDocDash

Creates API documentation for Elxir projects in the [Docsets format](http://kapeli.com/docsets) for use in Dash.app for  [MacOS X](http://kapeli.com/dash) or [iOS](http://kapeli.com/dash_ios). This is the first draft so problems may occur.

Template Design is generated using Fez Vrasta's [Bootstap Material Design]( http://fezvrasta.github.io/bootstrap-material-design/) framework

## Installation & Usage

Open up your `mix.exs` and add the following to your deps. *For reasons I have not yet found out mix will sometimes not grab the sqlite3 dep from the project so you have to require it from the using library for now.*

    {:sqlite3, ">= 1.0.1", github: "sergey-miryanov/erlang-sqlite3", only: :docs},
    {:ex_doc_dash, "~> 0.1.0", only: :docs}

Build your dependencies

    MIX_ENV=docs mix do deps.get, deps.compile

Now you can build your Dash.app documentation using the `docs.dash` task and it will be save in `./docs`.

    MIX_ENV=docs mix docs.dash

## Example of generating [Phoenix](https://github.com/phoenixframework/phoenix) Documentation

![ExDocDash Phoenix docs](https://us-east.manta.joyent.com/JonGretar/public/ExDocDash-Phoenix-1.gif)


## Contributing

All contributions are appreciated. Info on the Docset format can be found in the following links.

 * http://kapeli.com/docsets
 * http://kapeli.com/dash_guide
 * https://github.com/Kapeli/Dash-User-Contributions
