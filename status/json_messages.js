const status = require('./json_status')
const { success, failed } = require('./json_status')
const http = require('./json_codes')


const messages = {
	success: (data = []) => {
		return {
			code: http.ok.code,
			body: {
				success: true,
				status: success,
				data: data
			}
		}
	},

	failed: (error = '') => {
		return {
			code: http.conflict.code,
			body: {
				status: failed,
				error: {
					message: error,
					code: http.conflict.code
				}
			}
		}
	},

	make: ({ code = 200, success = true, data = undefined, errorMsg = '' }) => {
		let message = {
			code: code,
			body: {
				success: success,
				status: success ? status.success : status.failed
			}
		}

		if (data)
			message.body["data"] = data
		else if (errorMsg)
			message.body['error'] = {
				message: errorMsg,
				code: code
			}

		return message
	},

	ok: {
		code: http.ok.code,
		body: {
			success: true,
			status: success
		}
	},

	emptyList: {
		code: http.notFound.code,
		body: {
			success: false,
			status: failed,
			error: {
				message: "Empty List",
				code: http.notFound.code
			}
		}
	},

	notFound: {
		code: http.notFound.code,
		body: {
			success: false,
			status: failed,
			error: {
				message: http.notFound.desc,
				code: http.notFound.code
			}
		}
	},

	badRequest: {
		code: http.badRequest.code,
		body: {
			success: false,
			status: failed,
			error: {
				message: http.badRequest.desc,
				code: http.badRequest.code
			}
		}
	},

	forbidden: {
		code: http.forbidden.code,
		body: {
			success: false,
			status: failed,
			error: {
				message: http.forbidden.desc,
				code: http.forbidden.code
			}
		}
	},

	internalServerError: {
		code: http.internalServerError.code,
		body: {
			success: false,
			status: failed,
			error: {
				message: http.internalServerError.desc,
				code: http.internalServerError.code
			}
		}
	}
}

module.exports = messages
