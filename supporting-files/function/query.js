module.exports = {
	query: `query getUser($id: ID!) {
	    getUser (id: $id) {
	      	id
		    username
		    isSafe
		    _version
		 }
	}`,
};
