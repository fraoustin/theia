console.log("theia-login")


function params(param) {
	var vars = {};
	window.location.href.replace( location.hash, '' ).replace( 
		/[?&]+([^=&]+)=?([^&]*)?/gi, // regexp
		function( m, key, value ) { // callback
			vars[key] = value !== undefined ? decodeURIComponent(value) : '';
		}
	);

	if ( param ) {
		return vars[param] ? vars[param] : null;	
	}
	return vars;
}


function setLogIn(user, password){
  var xmlhttp = new XMLHttpRequest();
  url = window.location.protocol + '//' + window.location.host+window.location.pathname+ 'theia/'; 
  urlerror = window.location.protocol + '//' + window.location.host+window.location.pathname+ '?error=true'; 
  xmlhttp.open("GET", url.replace(/:\/\//, '://'+user+':'+password+'@'), true);
  xmlhttp.onreadystatechange=function() 
  {
    if(xmlhttp.readyState==4){
      if (xmlhttp.status == 200) {
        window.location.href = url;
      } else {
        window.location.href = urlerror;
      }
    }
  }
  xmlhttp.send();
}

function validForm(){
  setLogIn(document.getElementById('user').value, document.getElementById('password').value);
}

/* load page */
var params = params(),
  action = params['error'] ? params['error'] : 'false';
if (action == "true") {
  document.getElementById('error').classList.remove('hidden');
};

var passwordInput = document.getElementById("password");
passwordInput.addEventListener("keydown", function (e) {
  if (e.keyCode === 13) {  //checks whether the pressed key is "Enter"
    if ( document.getElementById('password').value.length > 0 && document.getElementById('user').value.length > 0) {
      setLogIn(document.getElementById('user').value, document.getElementById('password').value);
    }
  };
});
