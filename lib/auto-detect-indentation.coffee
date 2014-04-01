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
    lineCount = editor.getLineCount()
    shortest = 0
    numLinesWithTabs = 0
    numLinesWithSpaces = 0
    found = false

    # loop through more than 100 lines only if we haven't found any spaces yet
    for i in [0..lineCount-1] when (i < 100 or not found)

      # TODO: this don't help much until we can listen for an event post parsing
      continue if editor.isBufferRowCommented i
      firstSpaces = editor.lineForBufferRow(i).match /^([ \t]+)./m
      if firstSpaces
        found = true
        spaceChars = firstSpaces[1]

        if spaceChars[0] is '\t'
          numLinesWithTabs++
        else
          numLinesWithSpaces++
          # NOTE: Assumes nobody uses single space tabbing
          # This prevents C style block comments from tricking the detection
          # TODO: once we can listen for an 'after-parsed' event we can remove the <= 1 hack
          shortest = spaceChars.length if spaceChars.length < shortest or shortest <= 1


    if found
      if numLinesWithTabs > numLinesWithSpaces
        editor.setSoftTabs false
        editor.setTabLength atom.config.get("editor.tabLength")
      else
        editor.setSoftTabs true
        editor.setTabLength shortest

Subscriber.extend module.exports
