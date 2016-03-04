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
