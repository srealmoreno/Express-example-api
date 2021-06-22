const status = require('./json_status')
const { success, failed } = require('./json_status')
const http = require('./json_codes')


const messages = {
	success: (data) => {
		return {
			code: http.ok.code,
			body: {
				success: true,
				status: success,
				data: data
			}
		}
	},

	failed: (reason) => {
		return {
			code: http.conflict.code,
			body: {
				status: failed,
				reason: reason
			}
		}
	},

	make: ({ code, success, data = undefined, reason = undefined }) => {
		let message = {
			code: code,
			body: {
				success: success,
				status: success ? status.success : status.failed
			}
		}

		if (data)
			message.body["data"] = data
		else if (reason)
			message.body['reason'] = reason

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
			reason: "Empty List"
		}
	},

	notFound: {
		code: http.notFound.code,
		body: {
			success: false,
			status: failed,
			reason: http.notFound.desc
		}
	},

	badRequest: {
		code: http.badRequest.code,
		body: {
			success: false,
			status: failed,
			reason: http.badRequest.desc
		}
	},

	forbidden: {
		code: http.forbidden.code,
		body: {
			success: false,
			status: failed,
			reason: http.forbidden.desc
		}
	},

	internalServerError: {
		code: http.internalServerError.code,
		body: {
			success: false,
			status: failed,
			reason: http.internalServerError.desc
		}
	}
}

module.exports = messages
