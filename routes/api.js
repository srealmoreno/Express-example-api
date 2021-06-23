// references:
// https://expressjs.com/en/api.html#router
// https://expressjs.com/en/api.html#req.body
// https://expressjs.com/en/api.html#req.query
// https://expressjs.com/en/api.html#app.param
// https://expressjs.com/en/api.html#app.get.method
// https://expressjs.com/en/api.html#app.post.method
// https://expressjs.com/en/api.html#app.put.method
// https://expressjs.com/en/api.html#app.delete.method
// https://expressjs.com/en/api.html#res.status
// https://expressjs.com/en/api.html#res.json

const express = require('express')
const { Router } = require('express')

const database = require('../database/database')
const messages = require('../status/json_messages')

const router = Router()

express.response.sendResponse = function ({ code = 200, body = [] }) {
	this.status(code).json(body)
}

/*
req.body.id   = POST Method   (http data)
req.query.id  = SET Method	  (api/users?id=1&name=salvador)
req.params.id = URL property  (api/users/:id)
*/

//Routes
// Get all users
router.get('/api/users', async (req, res) => {
	console.log("GET all users")

	try {
		const users = await database.queryPromisify("SELECT * FROM users")
		if (users.length)
			return res.sendResponse(messages.success(users))

		return res.sendResponse(messages.emptyList)

	} catch (error) {
		console.error(error);
		return res.sendResponse(messages.internalServerError)
	}


	/*
	database.query("SELECT * FROM users", (err, rows, fields) => {
		if (err)
			return res.sendResponse(messages.internalServerError)

		if (rows.length)
			return res.sendResponse(messages.success(rows))

		return res.sendResponse(messages.emptyList)
	})
	*/
})

// Get one user by id
router.get('/api/users/:id', async (req, res) => {
	console.log(`GET user id = ${req.params.id}`)

	try {
		const [user] = await database.queryPromisify("SELECT * FROM users WHERE id=?", [req.params.id])
		if (user)
			return res.sendResponse(messages.success(user))

		return res.sendResponse(messages.notFound)
	} catch (error) {
		res.sendResponse(messages.internalServerError)
	}

	/*
	database.query("SELECT * FROM users WHERE id = ? ", [req.params.id], (err, rows, fields) => {
		if (err)
			return res.sendResponse(messages.internalServerError)

		if (rows[0])
			return res.sendResponse(messages.success(rows[0]))

		return res.sendResponse(messages.notFound)
	})
	*/
})

// Insert one user
router.post('/api/users', async (req, res) => {
	console.log("POST user")

	try {
		await database.queryPromisify('INSERT INTO users SET ?', [req.body])
		return res.sendResponse(messages.ok)
	} catch (error) {
		return res.sendResponse(messages.failed(error.message))
	}

	/*
	database.query("INSERT INTO users SET ?", [req.body], (err, rows, fields) => {
		if (err)
			return res.sendResponse(messages.failed(err.sqlMessage))

		res.sendResponse(messages.ok)
	})
	*/
})

// Insert one user (SET METHOD)
router.get('/api/user', async (req, res) => {
	console.log("SET user")

	try {
		await database.queryPromisify('INSERT INTO users SET ?', [req.query])
		return res.sendResponse(messages.ok)
	} catch (error) {
		return res.sendResponse(messages.failed(error.message))
	}

	/*
	database.query("INSERT INTO users SET ?", [req.query], (err, rows, fields) => {
		if (err)
			return res.sendResponse(messages.failed(err.sqlMessage))

		res.sendResponse(messages.ok)
	})
	*/
})


// Update one user by id (params method)
router.put('/api/users/:id', async (req, res) => {
	console.log(`PUT user ${req.params.id}`)

	try {
		const { affectedRows } = await database.queryPromisify('UPDATE users SET ? WHERE id = ?', [req.body, req.params.id])

		if (affectedRows != 0)
			res.sendResponse(messages.ok)
		else
			res.sendResponse(messages.notFound)

	} catch (error) {
		res.sendResponse(messages.internalServerError)
	}

	/*
	database.query('UPDATE users SET ? WHERE id = ?', [req.body, req.params.id], (err, rows, fields) => {
		if(err)
			return res.sendResponse(messages.internalServerError)

		if (rows.affectedRows == 0)
			return res.sendResponse(messages.notFound)

		res.sendResponse(messages.ok)
	})
	*/
})

// Update one user by id (POST method)
router.put('/api/users', async (req, res) => {
	console.log(`PUT user ${req.body.id}`)

	try {
		const { affectedRows } = await database.queryPromisify('UPDATE users SET ? WHERE id = ?', [req.body, req.body.id])

		if (affectedRows != 0)
			res.sendResponse(messages.ok)
		else
			res.sendResponse(messages.notFound)

	} catch (error) {
		res.sendResponse(messages.internalServerError)
	}

	/*
	database.query('UPDATE users SET ? WHERE id = ?', [req.body, req.body.id], (err, rows, fields) => {
		if(err)
			return res.sendResponse(messages.internalServerError)

		if (rows.affectedRows == 0)
			return res.sendResponse(messages.notFound)

		res.sendResponse(messages.ok)
	})
	*/
})

// Delete one user by id (params method)
router.delete('/api/users/:id', async (req, res) => {
	console.log(`DELETE user ${req.params.id}`)

	try {
		const { affectedRows } = await database.queryPromisify('DELETE FROM users WHERE id = ?', [req.params.id])

		if (affectedRows != 0)
			res.sendResponse(messages.ok)
		else
			res.sendResponse(messages.notFound)

	} catch (error) {
		res.sendResponse(messages.internalServerError)
	}

	/*
	database.query("DELETE FROM users WHERE id = ?", [req.params.id], (err, rows, fields) => {
		if(err)
			return res.sendResponse(messages.internalServerError)

		if (rows.affectedRows == 0)
			return res.sendResponse(messages.notFound)

		res.sendResponse(messages.ok)
	})
	*/
})

// Delete one user by id (POST method)
router.delete('/api/users', async (req, res) => {
	console.log(`DELETE user id = ${req.body.id}`)

	try {
		const { affectedRows } = await database.queryPromisify('DELETE FROM users WHERE id = ?', [req.body.id])

		if (affectedRows != 0)
			res.sendResponse(messages.ok)
		else
			res.sendResponse(messages.notFound)

	} catch (error) {
		res.sendResponse(messages.internalServerError)
	}

	/*
	database.query("DELETE FROM users WHERE id = ?", [req.body.id], (err, rows, fields) => {
		if (err)
			return res.sendResponse(messages.internalServerError)

		if (rows.affectedRows == 0)
			return res.sendResponse(messages.notFound)

		res.sendResponse(messages.ok)
	})
	*/
})

module.exports = router
