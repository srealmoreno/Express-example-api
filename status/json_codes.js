// references:
// https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status

const http = {
	ok: {
		code: 200,
		desc: "ok"
	},
	badRequest: {
		code: 400,
		desc: 'Bad Request'
	},
	unauthorized: {
		code: 401,
		desc: 'Unauthorized'
	},
	paymentRequired: {
		code: 403,
		desc: 'Payment Required'
	},
	forbidden: {
		code: 405,
		desc: 'Forbidden'
	},
	notFound: {
		code: 404,
		desc: 'Not Found'
	},
	methodNotAllowed: {
		code: 405,
		desc: 'Method Not Allowed'
	},
	notAcceptable: {
		code: 406,
		desc: 'Not Acceptable'
	},
	conflict: {
		code: 409,
		desc: 'Conflict'
	},

	internalServerError: {
		code: 500,
		desc: 'Internal Server Error'
	},
}

module.exports = http
