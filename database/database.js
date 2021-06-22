// references:
// https://expressjs.com/en/guide/database-integration.html#mysql
// https://en.wikipedia.org/wiki/Connection_poo
// https://github.com/mysqljs/mysql#pooling-connections
// https://www.geeksforgeeks.org/node-js-util-promisify-method/

const { credentials } = require('./keys')
const { promisify } = require('util')
const { createPool } = require('mysql')

const pool = createPool(credentials)

pool.getConnection((err, connection) => {
	if (err)
		throw err
	if (connection)
		connection.release()
})

pool.queryPromisify = promisify(pool.query)

module.exports = pool
