# Rib [![Build Status](https://secure.travis-ci.org/godfat/rib.png?branch=master)](http://travis-ci.org/godfat/rib) [![Coverage Status](https://coveralls.io/repos/godfat/rib/badge.png)](https://coveralls.io/r/godfat/rib)

by Lin Jen-Shin ([godfat](http://godfat.org))

## LINKS:

* [github](https://github.com/godfat/rib)
* [rubygems](https://rubygems.org/gems/rib)
* [rdoc](http://rdoc.info/github/godfat/rib)

## DESCRIPTION:

Ruby-Interactive-ruBy -- Yet another interactive Ruby shell

Rib is based on the design of [ripl][] and the work of [ripl-rc][], some of
the features are also inspired by [pry][]. The aim of Rib is to be fully
featured and yet very easy to opt-out or opt-in other features. It shall
be simple, lightweight and modular so that everyone could customize Rib.

[ripl]: https://github.com/cldwalker/ripl
[ripl-rc]: https://github.com/godfat/ripl-rc
[pry]: https://github.com/pry/pry

## REQUIREMENTS:

* Tested with MRI (official CRuby), Rubinius and JRuby.
* All gem dependencies are optional, but it's highly recommended to use
  Rib with [bond][] for tab completion.

[bond]: https://github.com/cldwalker/bond

## INSTALLATION:

    gem install rib

## SYNOPSIS:

![Screenshot](https://github.com/godfat/rib/raw/master/screenshot.png)

### As an interactive shell

As IRB (reads `~/.rib/config.rb` writes `~/.rib/history.rb`)

    rib

As Rails console

    rib rails

You could also run in production and pass arguments normally as you'd do in
`rails console` or `./script/console`

    rib rails production --sandbox --debugger

Note: You might need to add ruby-debug or ruby-debug19 to your Gemfile if
you're passing --debugger and using bundler together.

As Ramaze console

    rib ramaze

As Rack console

    rib rack

As a console for whichever the app in the current path
it should be (for now, it's either Rails, Ramaze or Rack)

    rib auto

If you're trying to use `rib auto` for a Rails app, you could also pass
arguments as if you were using `rib rails`. `rib auto` is merely passing
arguments.

    rib auto production --sandbox --debugger

As a fully featured interactive Ruby shell (as ripl-rc)

    rib all

As a fully featured app console (yes, some commands could be used together)

    rib all auto # or `rib auto all`, the order doesn't really matter

You can customize Rib's behaviour by setting a config file located at
`~/.rib/config.rb` or `~/.config/rib/config.rb`, or `$RIB_HOME/config.rb` by
setting `$RIB_HOME` environment variable. Since it's merely a Ruby script
which would be loaded into memory before launching Rib shell session, You can
put any customization or monkey patch there. Personally, I use all plugins
provided by Rib.

<https://github.com/godfat/dev-tool/blob/master/.config/rib/config.rb>

As you can see, putting `require 'rib/all'` into config file is exactly the
same as running `rib all` without a config file. What `rib all` would do is
merely require the file, and that file is also merely requiring all plugins,
but without **extra plugins**, which you should enable them one by one. This
is because most extra plugins are depending on other gems, or hard to work
with other plugins, or having strong personal tastes, so you won't want to
enable them all. Suppose you only want to use the core plugins and color
plugin, you'll put this into your config file:

``` ruby
require 'rib/core'
require 'rib/more/color'
```

You can also write your plugins there. Here's another example:

``` ruby
require 'rib/core'
require 'pp'
Rib.config[:prompt] = '$ '

module RibPP
  Rib::Shell.send(:include, self)

  def format_result result
    result_prompt + result.pretty_inspect
  end
end
```

So that we override the original format_result to pretty_inspect the result.
You can also build your own gem and then simply require it in your config
file. To see a list of overridable API, please read [api.rb][]

[api.rb]: https://github.com/godfat/rib/blob/master/lib/rib/api.rb

#### Basic configuration

Rib.config                 | Functionality
-------------------------- | -------------------------------------------------
ENV['RIB_HOME']            | Specify where Rib should store config and history
Rib.config[:config]        | The path where config should be located
Rib.config[:name]          | The name of this shell
Rib.config[:result_prompt] | Default is "=>"
Rib.config[:prompt]        | Default is ">>"
Rib.config[:binding]       | Context, default: TOPLEVEL_BINDING
Rib.config[:exit]          | Commands to exit, default [nil] # control+d

#### Plugin specific configuration

Rib.config                     | Functionality
------------------------------ | ---------------------------------------------
Rib.config[:completion]        | Completion: Bond config
Rib.config[:history_file]      | Default is "~/.rib/config/history.rb"
Rib.config[:history_size]      | Default is 500
Rib.config[:color]             | A hash of Class => :color mapping
Rib.config[:autoindent_spaces] | How to indent? Default is two spaces: '  '

#### List of core plugins

``` ruby
require 'rib/core' # You get all of the followings:
```

* `require 'rib/core/completion'`

  Completion from [bond][].

* `require 'rib/core/history'`

  Remember history in a history file.

* `require 'rib/core/strip_backtrace'`

  Strip backtrace before Rib.

* `require 'rib/core/readline'`

  Readline support.

* `require 'rib/core/multiline'`

  You can interpret multiple lines.

* `require 'rib/core/squeeze_history'`

  Remove duplicated input from history.

* `require 'rib/core/underscore'`

  Save the last result in `_` and the last exception in `__`.

#### List of more plugins

``` ruby
require 'rib/more' # You get all of the followings:
```

* `require 'rib/more/multiline_history_file'`

  Not only readline could have multiline history, but also the history file.

* `require 'rib/more/bottomup_backtrace'`

  Show backtrace bottom-up instead of the regular top-down.

* `require 'rib/more/color'`

  Class based colorizing.

* `require 'rib/more/multiline_history'`

  Make readline aware of multiline history.

* `require 'rib/more/anchor'`

  See _As a debugging/interacting tool_.

* `require 'rib/more/edit'`

  See _In place editing_.

### List of extra plugins

There's no `require 'rib/extra'` for extra plugins because they might not
be doing what you would expect or want, or having an external dependency,
or having conflicted semantics.

* `require 'rib/extra/autoindent'` This plugin is depending on:

  1. [readline_buffer][]
  2. readline plugin
  3. multiline plugin

  Which would autoindent your input.

* `require 'rib/extra/hirb'` This plugin is depending on:

  1. [hirb][]

  Which would print the result with hirb.

* `require 'rib/extra/debugger'` This plugin is depending on:

  1. [debugger][]

  Which introduces `Rib.debug`, which would do similar things as
  `Rib.anchor` but only more powerful. However, this is not well
  tested and might not work well. Please let me know if you have
  any issue using it, thanks!

* `require 'rib/extra/paging'` This plugin is depending on `less`.

  Which would pass the result to `less` (or `$PAGER` if set) if
  the result string is longer than the screen.

[readline_buffer]: https://github.com/godfat/readline_buffer
[hirb]: https://github.com/cldwalker/hirb
[debugger]: https://github.com/cldwalker/debugger

### As a debugging/interacting tool

Rib could be used as a kind of debugging tool which you can set break point
in the source program.

``` ruby
require 'rib/config' # This would load your Rib config
require 'rib/more/anchor'
                     # If you enabled anchor in config, then needed not
Rib.anchor binding   # This would give you an interactive shell
                     # when your program has been executed here.
Rib.anchor 123       # You can also anchor on an object.
```

But this might be called in a loop, you might only want to
enter the shell under certain circumstance, then you'll do:

``` ruby
require 'rib/debug'
Rib.enable_anchor do
  # Only `Rib.anchor` called in the block would launch a shell
end

Rib.anchor binding # No effect (no-op) outside the block
```

Anchor could also be nested. The level would be shown on the prompt,
starting from 1.

### In place editing

Whenever you called:

``` ruby
require 'rib/more/edit'
Rib.edit
```

Rib would open an editor according to `$EDITOR` (`ENV['EDITOR']`) for you.
By default it would pick vim if no `$EDITOR` was set. After save and leave
the editor, Rib would evaluate what you had input. This also works inside
an anchor. To use it, require either rib/more/edit or rib/more or rib/all.

### As a shell framework

The essence is:

``` ruby
require 'rib'
```

All others are optional. The core plugins are lying in `rib/core/*.rb`, and
more plugins are lying in `rib/more/*.rb`. You can read `rib/app/ramaze.rb`
and `bin/rib-ramaze` as a Rib App reference implementation, because it's very
simple, simpler than rib-rails.

## Other plugins and apps

* [rest-more][] `rib rest-core` Run as interactive rest-core client
* [rib-heroku][] `rib heroku` Run console on Heroku Cedar with your config

[rest-more]: https://github.com/cardinalblue/rest-more
[rib-heroku]: https://github.com/godfat/rib-heroku

## CONTRIBUTORS:

* Andrew Liu (@eggegg)
* ayaya (@ayamomiji)
* Lin Jen-Shin (@godfat)
* Mr. Big Cat (@miaout17)
* @bootleq
* @tka

## LICENSE:

Apache License 2.0

Copyright (c) 2011-2015, Lin Jen-Shin (godfat)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
