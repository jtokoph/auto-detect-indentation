{SelectListView} = require 'atom-space-pen-views'
IndentationChoices = require './indentation-choices'

# View to display a list of indentations to apply to the current editor.
module.exports =
class IndentationListView extends SelectListView
  initialize: ->
    super

    @addClass('indentation-selector')
    @list.addClass('mark-active')

  getFilterKey: ->
    'name'

  destroy: ->
    @cancel()

  viewForItem: (indentation) ->
    element = document.createElement('li')
    element.classList.add('active') if indentation.name is @currentIndentation
    element.textContent = indentation.name
    element

  cancelled: ->
    @panel?.destroy()
    @panel = null
    @currentIndentation = null

  confirmed: (indentation) ->
    editor = atom.workspace.getActiveTextEditor()
    editor.setSoftTabs indentation.softTabs
    if "tabLength" of indentation
      editor.setTabLength indentation.tabLength
    else
      editor.setTabLength atom.config.get("editor.tabLength", scope: editor.getRootScopeDescriptor().scopes)
    @cancel()

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  toggle: ->
    if @panel?
      @cancel()
    else
      editor = atom.workspace.getActiveTextEditor()
      if editor
        @currentIndentation = IndentationChoices.getIndentation editor
        @setItems(IndentationChoices.getIndentations())
        @attach()
