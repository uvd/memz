// server.js
const jsonServer = require('json-server')
const server = jsonServer.create()
const router = jsonServer.router('db.json')
const middlewares = jsonServer.defaults()

function authHeader (req, res, next) {
  res.header('Authorization', 'Bearer 4jh5v34jh5g4hg534jh5g43jh5g43hj534hjg543jh534ghj');
  next()
}

server.use(middlewares);
server.use(authHeader);

//In this example we simulate a server side error response
router.render = (req, res) => {
    res.setHeader('Access-Control-Expose-Headers', 'Location, Authorization')
    res.status(200).jsonp({"data":{"owner":"James","name":"Hack week","id":2, "slug": "hack-week", "end_date":"2017-10-12T01:03:00"}})
  }


server.use('/v1', router);

server.listen(3000, () => {
  console.log('JSON Server is running')
})

