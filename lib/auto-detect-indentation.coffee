{CompositeDisposable} = require 'atom'

commandDisposable = null
indentationListView = null
indentationStatusView = null

createIndentationListView = =>
  unless indentationListView?
    IndentationListView = require './indentation-list-view'
    indentationListView = new IndentationListView()
  indentationListView.toggle()

module.exports =
  activate: (state) ->
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @_handleLoad editor
    commandDisposable = atom.commands.add('atom-text-editor', 'indentation-selector:show', createIndentationListView)

  _handleLoad: (editor) ->
    @_loadSettingsForEditor editor
    editor.manualIndentation = false
    editor.syntaxLoaded = false

    @disposables.add editor.buffer.onDidSave =>
      unless editor.manualIndentation
        @_loadSettingsForEditor editor

    if editor.displayBuffer?.onDidTokenize
      @disposables.add editor.displayBuffer.onDidTokenize =>
        unless editor.syntaxLoaded
          editor.syntaxLoaded = true
          @_loadSettingsForEditor editor

  deactivate: ->
    @disposables.dispose()
    commandDisposable = null

  consumeStatusBar: (statusBar) ->
    IndentationStatusView = require './indentation-status-view'
    indentationStatusView = new IndentationStatusView().initialize(statusBar)
    indentationStatusView.attach()

  _loadSettingsForEditor: (editor) ->
    # Disable atom's native detection of spaces/tabs
    editor.shouldUseSoftTabs = ->
      @softTabs

    # Trigger "did-change-indentation" event when indentation is changed
    editor.setSoftTabs = (@softTabs) ->
      @emitter.emit 'did-change-indentation'
      @softTabs

    # Trigger "did-change-indentation" event when indentation is changed
    editor.setTabLength = (tabLength) ->
      value = @displayBuffer.setTabLength(tabLength)
      @emitter.emit 'did-change-indentation'
      value

    lineCount = editor.getLineCount()
    shortest = 0
    numLinesWithTabs = 0
    numLinesWithSpaces = 0
    found = false

    # loop through more than 100 lines only if we haven't found any spaces yet
    for i in [0..lineCount-1] when (i < 100 or not found)

      # Skip comments
      continue if editor.isBufferRowCommented i

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

  config:
    indentationTypes:
      type: 'array'
      items:
        type: 'object'
        properties:
          name:
            type: 'string'
          softTabs:
            type: 'boolean'
          tabLength:
            type: 'integer'
      default:
        [
          {
            name: "2 Spaces"
            softTabs: true
            tabLength: 2
          }
          {
            name: "4 Spaces"
            softTabs: true
            tabLength: 4
          }
          {
            name: "8 Spaces"
            softTabs: true
            tabLength: 8
          }
          {
            name: "Tabs (default width)"
            softTabs: false
          }
          {
            name: "Tabs (2 wide)"
            softTabs: false
            tabLength: 2
          }
          {
            name: "Tabs (4 wide)"
            softTabs: false
            tabLength: 4
          }
          {
            name: "Tabs (8 wide)"
            softTabs: false
            tabLength: 8
          }
        ]
