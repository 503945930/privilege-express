# privilege-express
An ExpressJS interface for the privilege module.

## Example Usage

```javascript

var app    = require('express')()
var privilege = require('privilege')({
  pathMap: {
    '/my/test/path': 'my:test:path:list'
    '/my/test/path/:id': 'my:test:path:item'
    '/my/other/:id': 'my:other:item'
    '/my/other': 'my:other:list'
    '/my/other/:id/action': 'my:other:item:action'
  },
  roleMap: {
    'root': {
      '*': [ 'get', 'post', 'put', 'delete' ] // root can access all
    },
    'reader': {
      'my:test:path:list': [ 'get' ]
      'my:test:path:item': [ 'get' ]
      'my:other:item': [ 'get' ]
      'my:other:list': [ 'get' ]
    }
    'writer': {
      'my:test:path:list': [ 'get' ]
      'my:test:path:item': [ 'get', 'post', 'put', 'delete' ]
      'my:other:item': [ 'get', 'post', 'put', 'delete' ]
      'my:other:item:action': [ 'post' ]
      'my:other:list': [ 'get' ]
    }
  }
});

app.use(privilege);

```
