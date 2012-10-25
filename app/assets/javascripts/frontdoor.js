


$(function() {

    $("#banner-login-btn").click(function() {
        login_action_handler();
    });
    $("#login-btn").click(function() {
        login_action_handler();
    });
    $("#banner-logout-btn").click(function(){
        logout_action_handler();
    });
    $(".nav-tabs li ").click(function() {
        $(".active").removeClass("active");
        $(this).addClass("active");
    });
});


function login_action_handler() {
    NAU.log("Login");

    $.ajax({
        url: '/login',
        type: 'GET',
        success: function() {
            NAU.log("Navigating to login page.");
        }
    });
}

function logout_action_handler() {
    NAU.log("Logout");

    $.ajax({
        url: '/logout',
        type: 'GET',
        success: function() {
            NAU.log("Session destroyed. Navigating back to the homepage.");
            // NAU.navigate("/");
        }
    });
}