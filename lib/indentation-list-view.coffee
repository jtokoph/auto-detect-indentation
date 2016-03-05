{SelectListView} = require 'atom-space-pen-views'
IndentationManager = require './indentation-manager'

# View to display a list of indentations to apply to the current editor.
module.exports =
class IndentationListView extends SelectListView
  initialize: ->
    super

    @addClass('auto-detect-indentation-selector')
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
    IndentationManager.setIndentation(editor, indentation)
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
        @currentIndentation = IndentationManager.getIndentation editor
        @setItems(IndentationManager.getIndentations())
        @attach()
