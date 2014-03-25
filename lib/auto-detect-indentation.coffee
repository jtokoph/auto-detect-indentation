{Subscriber} = require 'emissary'

module.exports =
  activate: (state) ->
    @subscribe atom.workspace.eachEditor (editor) =>
      @_handleLoad editor

  _handleLoad: (editor) ->
    @_loadSettingsForEditor editor
    @subscribe editor.buffer, 'saved', =>
        @_loadSettingsForEditor editor

  deactivate: ->
    @unsubscribe()

  _loadSettingsForEditor: (editor) ->
    firstSpaces = editor.buffer.getText().match /^([ \t]+)/m
    if firstSpaces
      spaceChars = firstSpaces[1]
      if /^\t/.test spaceChars
        editor.setSoftTabs false
      else
        editor.setSoftTabs true
        editor.setTabLength spaceChars.length

Subscriber.extend module.exports
