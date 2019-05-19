const fs = require('fs')
const path = require('path')
const fastify = require('fastify')({  http2: false,})

fastify.get('/',  function (req, reply) {
    reply.send('hello world!')
  })

fastify.listen(9057, "0.0.0.0", err => {
  if (err) throw err
  console.log(`server listening on ${fastify.server.address().port}`)
})