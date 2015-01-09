_          = require 'underscore'
Backbone   = require 'backbone'
Backbone.$ = require 'jquery'

class View extends Backbone.View

  template: require '../templates/template'

  initialize: ->
    underscoreTest = _.last([0,1,2, 'hi mom!'])
    console.log underscoreTest
    @render()

  render: ->
    @$el.html @template
      description: 'Starter Gulp + Browserify project to demonstrate some common tasks:'
      tools: [
        'CommonJS bundling and watching'
        'Working with multiple bundles'
        'Factoring out shared dependencies'
        'Live reloading across devices'
        'JS transforms and compiling'
        'CSS preprocessing: Stylus with Nib and Jeet'
        'Image optimization'
        'Non common-js plugins with common-js dependencies'
        'Using modules already bundled with other modules'
      ]

module.exports = View
