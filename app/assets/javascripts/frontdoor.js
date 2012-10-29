


$(function() {

    $("#banner-logout-btn").click(function(){
        logout_action_handler();
    });
    $(".nav-tabs li ").click(function() {
        $(".active").removeClass("active");
        $(this).addClass("active");
    });
});

function logout_action_handler() {
    NAU.log("Logout");

    $.ajax({
        url: '/logout',
        type: 'GET',
        success: function() {
            NAU.log("Session destroyed. Navigating back to the homepage.");
            NAU.navigate("/");
        }
    });
}