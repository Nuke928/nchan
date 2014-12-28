VENDOR = "vendor"
requirejs.config
  paths:
    'jquery': "#{VENDOR}/jquery.min"
    'backbone': "#{VENDOR}/backbone.min"
    'underscore': "#{VENDOR}/underscore.min"
    'underscore.string': "#{VENDOR}/underscore.string.min"
    'jade': "#{VENDOR}/jade.min"
  shim:
    'jquery': exports: '$'
    'backbone':
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    'underscore': exports: '_'
    'underscore.string':
      deps: ['underscore']
    'jade': exports: 'jade'

requirejs ['jquery', 'underscore.string'], ($) ->
  $(document).ready () ->
    # Click on a post's id will automatically cite it
    $('a').click (event) ->
      cid = event.target.id
      if _.str.startsWith cid, 'c'
        id = _.str.ltrim cid, 'c'
        $('#commentarea').val (i, val) ->
          val + '>>' + id + '\n'