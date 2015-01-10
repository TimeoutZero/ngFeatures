'use strict'

# =============================================
# LoginController
# =============================================
describe 'Filter: EnumMessagesFilter', ()->

  # =============================================
  # Import modules
  # =============================================
  beforeEach module('MyAngularOmakase.scripts')

  # =============================================
  # Variables
  # =============================================
  MessagesFilter  = null

  # =============================================
  # Inject dependencies
  # =============================================
  beforeEach inject (EnumMessagesFilterFilter) ->
    MessagesFilter = EnumMessagesFilterFilter()


  # =============================================
  # Tests
  # =============================================
  describe 'get method ', ->

    it 'Should get a valid message', ()->
      message = MessagesFilter.get('user.does.not.exist')

      expect(message).toBeDefined()

    it 'Should return undefined for a invalid key', ->
      message = MessagesFilter.get(null)

      expect(message).toBeUndefined()


  describe 'getAll method ', ->

    it 'Should get all messages', ()->
      messages = MessagesFilter.getAll()

      expect(messages).toBeDefined() 
      expect(typeof messages).toEqual('object')

