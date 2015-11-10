
Privilege   = require 'privilege'
createError = require 'http-errors'

module.exports  = (options) ->

  pathMap       = if options.pathMap?.getToken then options.pathMap else
    Privilege.PermissionMap.fromJson options.pathMap

  roleMap       = if options.roleMap?.check then options.roleMap else
    Privilege.RoleMap.fromJson options.roleMap

  notAuthorized = if options.notAuthorized then options.notAuthorized else
    (req, res, next) -> next (createError 403, 'Forbidden')

  privilege     = Privilege
    pathMap: pathMap
    roleMap: roleMap
    contextToRoles: options.contextToRoles

  return (req, res, next) ->

    privilege req, req.originalUrl, req.method, (err, is_allowed) ->
      if err
        next(err)
      else if not is_allowed
        notAuthorized req, res, next
      else
        next()
