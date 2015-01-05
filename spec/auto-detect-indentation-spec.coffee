{WorkspaceView} = require 'atom'
Path = require 'path'

describe 'auto-detect-indentation', ->
  [editor, workspace, workspaceView, activationPromise] = []

  beforeEach ->

    waitsForPromise ->
      atom.packages.activatePackage("auto-detect-indentation")

    # Require language-c in order to parse comments
    waitsForPromise ->
      atom.packages.activatePackage("language-c")
      atom.packages.activatePackage("language-sass")

    atom.workspaceView = workspaceView = new WorkspaceView
    atom.workspace = workspace = atom.workspaceView.model

  afterEach ->
    workspace.destroy()

  describe 'when a file is opened with 4 spaces', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 2
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/4-spaces.rb')
      editor = workspace.getActiveEditor()

    it "will report 4 spaces", ->
      expect(editor.getTabLength()).toBe 4

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true

  describe 'when a file is opened with 2 spaces', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 4
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/2-spaces.py')
      editor = workspace.getActiveEditor()

    it "will report 2 spaces", ->
      expect(editor.getTabLength()).toBe 2

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true


  # Issue #2
  describe 'when a file is opened with 4 spaces but first spacing is longer', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 2
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/lined-up-params.py')
      editor = workspace.getActiveEditor()

    it "will report 4 spaces", ->
      expect(editor.getTabLength()).toBe 4

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true

  describe 'when a file is opened with tabs', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 4
      atom.config.set "editor.softTabs", true
      workspaceView.openSync Path.join(__dirname, './fixtures/tabs.rb')
      editor = workspace.getActiveEditor()

    it "will report hard tabs", ->
      expect(editor.getSoftTabs()).toBe false

    it "will report tab length of 4", ->
      expect(editor.getTabLength()).toBe 4

  describe 'when a file is opened with mostly tabs but has one line with spaces', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 2
      atom.config.set "editor.softTabs", true
      workspaceView.openSync Path.join(__dirname, './fixtures/mostly-tabs.rb')
      editor = workspace.getActiveEditor()

    it "will report hard tabs", ->
      expect(editor.getSoftTabs()).toBe false

    it "will report tab length of 2", ->
      expect(editor.getTabLength()).toBe 2

  describe 'when a file is opened with mostly spaces but a couple lines have tabs', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 2
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/mostly-spaces.rb')
      editor = workspace.getActiveEditor()

    it "will report 6 spaces", ->
      expect(editor.getTabLength()).toBe 6

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true

  describe 'when a file is opened with c style block comments', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 4
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/c-style-block-comments.c')
      editor = workspace.getActiveEditor()

    it "will report 2 spaces", ->
      expect(editor.getTabLength()).toBe 2

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true

  describe 'when a file is opened with c style block comments near the end or line 100', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 4
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/c-style-block-comments-at-end.c')
      editor = workspace.getActiveEditor()

    it "will report 2 spaces", ->
      expect(editor.getTabLength()).toBe 2

    it "will report soft tabs", ->
      expect(editor.getSoftTabs()).toBe true

  describe 'when a file is opened only comments', ->

    beforeEach ->
      atom.config.set "editor.tabLength", 4
      atom.config.set "editor.softTabs", false
      workspaceView.openSync Path.join(__dirname, './fixtures/only-comments.scss')
      editor = workspace.getActiveEditor()

    it "will pass this test because it didn't infinite loop", ->
      expect(true).toBe true

    it "will report 4 spaces", ->
      expect(editor.getTabLength()).toBe 4

    it "will report tabs", ->
      expect(editor.getSoftTabs()).toBe false
