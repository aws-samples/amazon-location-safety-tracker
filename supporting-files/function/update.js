module.exports = {
	update: `mutation updateUser($input: UpdateUserInput!) {
	  updateUser(input: $input){
	    id
	    isSafe
	    username
	    _lastChangedAt
    	_version
   		_deleted
	  }
	}`,
};
