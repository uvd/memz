// server.js
const jsonServer = require('json-server')
const server = jsonServer.create()
const router = jsonServer.router('db.json')
const middlewares = jsonServer.defaults()

server.use(middlewares)

// In this example we simulate a server side error response
router.render = (req, res) => {
    res.status(400).jsonp({
      errors: {
          "name": ["too long", "too stupid"],
          "owner": ["Too short"],
          "endDateTime": ["Wrong date, how did you manage that"]
      }
    })
  }


server.use('/v1', router);

server.listen(3000, () => {
  console.log('JSON Server is running')
})

