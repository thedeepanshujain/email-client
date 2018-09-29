// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .
//= require jquery
//= require bootstrap

$(document).ready(function(){

  const THRESHOLD = 300;
  const $paginationElem = $("#pagination");
  const $window = $(window);
  const $document = $(document);
  const $tabItem = $(".tab-item")

  $('.disable_anchor').click()

  $tabItem.click(function(){
    var path = $(this).attr('data-click-path');

    $.ajax({
        url: path
      }).done(function (result) {
        console.log($('#div_messages').children().length)
        $('#div_messages').html(result.messages);
        $paginationElem.attr('data-pagination-endpoint', path+result.next_page_token)
        isPaginating = false;
      });
  })

  $('.show_message_div').click(function(){
    var path = $(this).attr('href');
    console.log('div clicked')
    window.location.href=path
  })



  /* initialize pagination */
  $paginationElem.hide()
  let isPaginating = false

  /* listen to scrolling */
  $window.on('scroll', _.debounce(function () {
    paginationUrl = $paginationElem.attr('data-pagination-endpoint');
    if (!isPaginating && $window.scrollTop() > $document.height() - $window.height() - THRESHOLD) {
      isPaginating = true;
      $paginationElem.show();
      
      $.ajax({
        url: paginationUrl
      }).done(function (result) {
        $('#div_messages').append(result.messages);
        $paginationElem.attr('data-pagination-endpoint', update_path(paginationUrl, result.next_page_token))
        isPaginating = false;
      });
      
      
    }
  }, 100));

})

function update_path(paginationUrl, next_page_token) {
  paginationArray = paginationUrl.split('/')
  paginationArray[paginationArray.length - 1] = next_page_token
  return paginationArray.join('/')
}