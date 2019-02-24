console.log('doh!');

function myFunction() {
    var x = document.getElementById("nav-bar");
    if (x.className === "NavBar") {
        x.className += " responsive";
    } else {
        x.className = "NavBar";
    }
}