
assert    = require 'assert'
Privilege = require '../../src/index'
privilege = null

root      = roles: [ 'root' ]

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
        '/test-thing/path/:id': 'test:thing:path'
      roleMap:
        'root':
          '*': [ 'get', 'post', 'put', 'delete' ]
        'role-one':
          'test:path': [ 'get', 'post' ]
          'test:path:action': [ 'post', 'put' ]
          'test:other:path': [ 'post', 'delete' ]
          'test:thing:path': [ 'get' ]
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


  it 'should allow access on an undefined path to a role with a "*" privilege',
  (done) ->
    req  =
      originalUrl: '/does/not/exist'
      method: 'POST'
      user: root

    privilege req, {}, (err) ->
      assert.equal err, null
      done()

  it 'should ignore any URL parameters', (done) ->

    req   =
      originalUrl: '/test/path/123/action?some=param'
      method: 'POST'
      user: user1

    privilege req, {}, (err) ->
      assert.equal err, null
      done()

  it 'should allow urls with dashes', (done) ->

    req   =
      originalUrl: '/test-thing/path/123?some=param'
      method: 'GET'
      user: user1

    privilege req, {}, (err) ->
      assert.equal err, null
      done()

  it 'should respond with an error if a url is not provided', (done) ->

    req  =
      method: 'POST'
      user: user1

    privilege req, {}, (err) ->
      assert.equal err.status, 403
      assert.equal err.message, 'Forbidden'
      done()


  it 'should use a custom pathMap if the provided object has a "getToken" ' +
  "method", (done) ->
    pathMap =
      getToken: (path) -> 'only token'

    roleMap =
      'role1':
        'only token': [ 'get' , 'post' ]

    req  =
      originalUrl: '/some/test'
      method: 'get'
      user: roles: [ 'role1' ]

    privilege = Privilege
      pathMap: pathMap
      roleMap: roleMap

    privilege req, {}, (err) ->
      assert.equal err, null
      done()


  it 'should use a custom roleMap if the provided object has a "check" ' +
  'method', (done) ->

    privilege = Privilege
      pathMap:
        '/some/test': 'some:test'
      roleMap:
        'check': (roles, token, method)-> return true if token is 'some:test'

    req  =
      originalUrl: '/some/test'
      method: 'get'
      user: roles: [ 'role1' ]

    privilege req, {}, (err) ->
      assert.equal err, null
      done()


  it 'should catch an error thrown in a user provided function', (done) ->

    privilege = Privilege
      pathMap:
        getToken: (path) -> throw new Error('test catch')
      roleMap:
        check: (roles, token, method) -> return true

    req  =
      originalUrl: '/something'
      method: 'get'
      user: root

    privilege req, {}, (err) ->
      assert.equal err.message, 'test catch'
      done()


  it 'should accept a custom notAuthorized method', (done) ->

    privilege = Privilege
      pathMap:
        getToken: (path) -> 'test'
      roleMap:
        check: (roles, token, method) -> return false
      notAuthorized: (req, res, next) -> next (new Error 'MyCustomError')

    req  =
      originalUrl: '/blah'
      method: 'post'
      user: roles: [ 'foo' ]

    privilege req, {}, (err) ->
      assert.equal err.message, 'MyCustomError'
      done()
