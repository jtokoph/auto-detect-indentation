{CompositeDisposable} = require 'atom'

module.exports =
  activate: (state) ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @_handleLoad editor

  _handleLoad: (editor) ->
    @_loadSettingsForEditor editor
    @disposables.add editor.buffer.onDidSave =>
      @_loadSettingsForEditor editor

  deactivate: ->
    @disposables.dispose()

  _loadSettingsForEditor: (editor) ->
    lineCount = editor.getLineCount()
    shortest = 0
    numLinesWithTabs = 0
    numLinesWithSpaces = 0
    found = false

    # loop through more than 100 lines only if we haven't found any spaces yet
    for i in [0..lineCount-1] when (i < 100 or not found)

      # TODO: this doesn't help much until we can listen for an event post parsing
      # continue if editor.isBufferRowCommented i

      firstSpaces = editor.lineTextForBufferRow(i).match /^([ \t]+)[^ \t]/m

      if firstSpaces
        spaceChars = firstSpaces[1]

        if spaceChars[0] is '\t'
          numLinesWithTabs++
        else
          length = spaceChars.length

          # assume nobody uses single space spacing
          continue if length is 1

          numLinesWithSpaces++

          shortest = length if length < shortest or shortest is 0

        found = true

    if found
      if numLinesWithTabs > numLinesWithSpaces
        editor.setSoftTabs false
        editor.setTabLength atom.config.get("editor.tabLength", scope: editor.getRootScopeDescriptor().scopes)
      else
        editor.setSoftTabs true
        editor.setTabLength shortest
    else
        editor.setSoftTabs atom.config.get("editor.softTabs", scope: editor.getRootScopeDescriptor().scopes)
        editor.setTabLength atom.config.get("editor.tabLength", scope: editor.getRootScopeDescriptor().scopes)
