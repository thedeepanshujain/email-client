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
//= require lodash

$(document).ready(function(){

  const THRESHOLD = 300;
  const $paginationElem = $("#pagination");
  const $window = $(window);
  const $document = $(document);
  const paginationUrl = $paginationElem.attr('data-pagination-endpoint');


  console.log(paginationUrl)
  // $(paginationElem.attributes).each(function(index, attribute) {
  //   console.log("Attribute:"+attribute.nodeName+" | Value:"+attribute.nodeValue);
  // });

  /* initialize pagination */
  $paginationElem.hide()
  let isPaginating = false

  /* listen to scrolling */
  $window.on('scroll', _.debounce(function () {
    if (!isPaginating && $window.scrollTop() > $document.height() - $window.height() - THRESHOLD) {
      isPaginating = true;
      $paginationElem.show();
      $.ajax({
        url: paginationUrl
      }).done(function (result) {
        console.log($('#div_messages').children().length)
        $('#div_messages').append(result.messages);
        $paginationElem.attr('data-pagination-endpoint', '/messages/page/'+result.next_page_token)
        isPaginating = false;
      });
    }
  }, 100));

})