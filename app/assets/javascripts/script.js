$(window).scroll(function() {
  if($(".nav-landing").length > 0){
    if ($(document).scrollTop() > 400) {
      $('nav').removeClass('navbar-transparent');
      $('nav').addClass('navbar-default');
    } else {
      $('nav').addClass('navbar-transparent');
      $('nav').removeClass('navbar-default');
    }
  }
});
$(document).ready(function() {
  $('.bottom-arrow.animate').click(function () {
    $("html, body").animate({scrollTop: 660}, 1500);
  });
});