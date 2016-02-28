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
