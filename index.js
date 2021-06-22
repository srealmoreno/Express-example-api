// references
// https://expressjs.com/en/api.html*

const express = require('express')
const { urlencoded, json } = require('express')
const app = express()
const PORT = 3000
const IP = "127.0.0.1"

console.clear()

// MiddleWares
app.use(urlencoded({ extended: false }))
app.use(json())


app.get('/', (req, res) => {
	return res.send("Hello World!")
})

app.use(require('./routes/api'))

//Server
app.listen(PORT, IP, () => console.log(`Listening on port http://${IP}:${PORT}`))
