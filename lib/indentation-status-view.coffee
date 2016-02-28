{Disposable} = require 'atom'
IndentationChoices = require './indentation-choices'

class IndentationStatusView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('indentation-status', 'inline-block')
    @indentationLink = document.createElement('a')
    @indentationLink.classList.add('inline-block')
    @indentationLink.href = '#'
    @appendChild(@indentationLink)
    @handleEvents()
    this

  attach: ->
    @statusBarTile?.destroy()
    @statusBarTile =
      @statusBar.addRightTile(item: this, priority: 10)
    @updateIndentationText()

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    @configSubscription = atom.config.observe 'indentation-selector.showOnRightSideOfStatusBar', =>
      @attach()

    clickHandler = => atom.commands.dispatch(atom.views.getView(@getActiveTextEditor()), 'indentation-selector:show')
    @addEventListener('click', clickHandler)
    @clickSubscription = new Disposable => @removeEventListener('click', clickHandler)

    @subscribeToActiveTextEditor()

  destroy: ->
    @activeItemSubscription?.dispose()
    @indentationSubscription?.dispose()
    @paneOpenSubscription?.dispose()
    @paneCreateSubscription?.dispose()
    @paneDestroySubscription?.dispose()
    @clickSubscription?.dispose()
    @configSubscription?.dispose()
    @statusBarTile.destroy()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    workspace = atom.workspace
    editor = workspace.getActiveTextEditor()
    @indentationSubscription?.dispose()
    @indentationSubscription = editor?.emitter?.on 'did-change-indentation', =>
      @updateIndentationText()
    @paneOpenSubscription?.dispose()
    @paneOpenSubscription = workspace.onDidOpen (event) =>
      @updateIndentationText()
    @paneCreateSubscription?.dispose()
    @paneCreateSubscription = workspace.onDidAddPane (event) =>
      @updateIndentationText()
    @paneDestroySubscription?.dispose()
    @paneDestroySubscription = workspace.onDidDestroyPaneItem (event) =>
      @updateIndentationText()
    @updateIndentationText()

  updateIndentationText: ->
    editor = @getActiveTextEditor()
    if editor
      indentationName = IndentationChoices.getIndentation editor
      @indentationLink.textContent = indentationName
      @style.display = ''
    else
      @style.display = 'none'

module.exports = document.registerElement('indentation-selector-status', prototype: IndentationStatusView.prototype)
