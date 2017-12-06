# Lolcommits HipChat

[![Gem Version](https://img.shields.io/gem/v/lolcommits-hipchat.svg?style=flat)](http://rubygems.org/gems/lolcommits-hipchat)
[![Travis Build Status](https://travis-ci.org/lolcommits/lolcommits-hipchat.svg?branch=master)](https://travis-ci.org/lolcommits/lolcommits-hipchat)
[![Maintainability](https://img.shields.io/codeclimate/maintainability/lolcommits/lolcommits-hipchat.svg)](https://codeclimate.com/github/lolcommits/lolcommits-hipchat/maintainability)
[![Test Coverage](https://img.shields.io/codeclimate/c/lolcommits/lolcommits-hipchat.svg)](https://codeclimate.com/github/lolcommits/lolcommits-hipchat/test_coverage)
[![Gem Dependency Status](https://gemnasium.com/badges/github.com/lolcommits/lolcommits-hipchat.svg)](https://gemnasium.com/github.com/lolcommits/lolcommits-hipchat)

[lolcommits](https://lolcommits.github.io/) takes a snapshot with your webcam
every time you git commit code, and archives a lolcat style image with it. Git
blame has never been so much fun!

This plugin shares lolcommit images to a HipChat room, along with a randomized
message with the commit SHA. Your lolcommit will appear like this (perhaps
without the horse):

![example
commit](https://github.com/lolcommits/lolcommits-hipchat/raw/master/assets/images/example-commit.png)


## Requirements

* [Lolcommits](https://lolcommits.github.io/) >= 0.9.5
* Ruby >= 2.0.0
* A webcam
* [ImageMagick](http://www.imagemagick.org)
* [ffmpeg](https://www.ffmpeg.org) (optional) for animated gif capturing

## Installation

After installing the lolcommits gem, install this plugin with:

    $ gem install lolcommits-hipchat

Visit `https://your-team.hipchat.com/account/api` to create a new API token with
the 'Send Message' scope set. Then configure the plugin to enable it:

    $ lolcommits --config -p hipchat
    # set enabled to `true`
    # when prompted, enter your HipChat team name, API token and room (name or id)

That's it! The next lolcommit will be shared to your HipChat room. To disable,
uninstall this gem or use:

    $ lolcommits --config -p hipchat
    # and set enabled to `false`

## Development

Check out this repo and run `bin/setup`, this will install all dependencies and
generate docs. Use `bundle exec rake` to run all tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt that will allow you to
experiment with the gem code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

## Docs

Generate docs for this gem with:

    $ rake rdoc

## Troubles?

If you think something is broken or missing, please raise a new
[issue](https://github.com/lolcommits/lolcommits-hipchat/issues). Take
a moment to check it hasn't been raised in the past (and possibly closed).

## Contributing

Bug [reports](https://github.com/lolcommits/lolcommits-hipchat/issues) and [pull
requests](https://github.com/lolcommits/lolcommits-hipchat/pulls) are welcome on
GitHub.

When submitting pull requests, remember to add tests covering any new behaviour,
and ensure all tests are passing on [Travis
CI](https://travis-ci.org/lolcommits/lolcommits-hipchat). Read the
[contributing
guidelines](https://github.com/lolcommits/lolcommits-hipchat/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/lolcommits/lolcommits-hipchat/blob/master/CODE_OF_CONDUCT.md)
for more details.

## License

The gem is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Links

* [Travis CI](https://travis-ci.org/lolcommits/lolcommits-hipchat)
* [Code Climate](https://codeclimate.com/github/lolcommits/lolcommits-hipchat)
* [Test Coverage](https://codeclimate.com/github/lolcommits/lolcommits-hipchat/coverage)
* [RDoc](http://rdoc.info/projects/lolcommits/lolcommits-hipchat)
* [Issues](http://github.com/lolcommits/lolcommits-hipchat/issues)
* [Report a bug](http://github.com/lolcommits/lolcommits-hipchat/issues/new)
* [Gem](http://rubygems.org/gems/lolcommits-hipchat)
* [GitHub](https://github.com/lolcommits/lolcommits-hipchat)
