
assert    = require 'assert'
Privilege = require '../../src/index'
privilege = null

user1     = roles: [ 'role-one' ]

user2     = roles: [ 'role-two' ]

user3     = roles: [ 'role-one', 'role-two' ]


describe 'Privilege Express', ->

  beforeEach ->
    privilege = Privilege
      pathMap:
        '/test/path/:id': 'test:path'
        '/test/path/:id/action': 'test:path:action'
        '/test/other/path/:id': 'test:other:path'
      roleMap:
        'root':
          '*': [ 'get', 'post', 'put', 'delete' ]
        'role-one':
          'test:path': [ 'get', 'post' ]
          'test:path:action': [ 'post', 'put' ]
          'test:other:path': [ 'post', 'delete' ]
        'role-two':
          'test:path': [ 'get', 'post' ]
          'test:path:action': [ 'get', 'post', 'put' ]
          'test:other:path': [ 'post', 'delete' ]


  it 'should generate an HTTP Error on a disallowed GET request', (done) ->

    req  =
      originalUrl: '/test/path/123/action'
      method: 'GET'
      user: user1

    privilege req, {}, (err) ->
      assert.equal err.status, 403
      assert.equal err.message, 'Forbidden'
      done()

  it 'should not generate an error for an allowed GET request', (done) ->

    req  =
      originalUrl: '/test/path/123'
      method: 'GET'
      user: user1

    privilege req, {}, (err) ->
      assert.equal err, null
      done()
