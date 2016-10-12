manuallyIndented = new WeakSet()

module.exports =
  getIndentation: (editor) ->
    softTabs = editor.getSoftTabs()
    tabLength = editor.getTabLength()
    if softTabs
      indentationName = tabLength + ' Spaces'
    else
      indentationName = 'Tabs (' + tabLength + ' wide)'
    indentationName

  getIndentations: ->
    atom.config.get("auto-detect-indentation.indentationTypes")

  autoDetectIndentation: (editor) ->
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

    softTabs = null
    tabLength = null

    if found
      if numLinesWithTabs > numLinesWithSpaces
        softTabs = false
      else
        softTabs = true
        tabLength = shortest

    return (
      softTabs: softTabs
      tabLength: tabLength
    )

  setIndentation: (editor, indentation, automatic = false) ->
    unless automatic
      manuallyIndented.add(editor)
    
    if indentation.softTabs?
      editor.setSoftTabs indentation.softTabs
    else
      editor.setSoftTabs atom.config.get("editor.softTabs", scope: editor.getRootScopeDescriptor().scopes)
    
    if indentation.tabLength?
      editor.setTabLength indentation.tabLength
    else
      editor.setTabLength atom.config.get("editor.tabLength", scope: editor.getRootScopeDescriptor().scopes)

  isManuallyIndented: (editor) ->
    return manuallyIndented.has editor
