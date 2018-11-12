// FLAT Theme v2.0
(function($) {
  $.fn.retina = function(retina_part) {
    // Set default retina file part to '-2x'
    // Eg. some_image.jpg will become some_image-2x.jpg
    var settings = {
      'retina_part': '-2x'
    };
    if (retina_part) jQuery.extend(settings, {
      'retina_part': retina_part
    });
    if (window.devicePixelRatio >= 2) {
      this.each(function(index, element) {
        if (!$(element).attr('src')) return;

        var checkForRetina = new RegExp("(.+)(" + settings['retina_part'] + "\\.\\w{3,4})");
        if (checkForRetina.test($(element).attr('src'))) return;

        var new_image_src = $(element).attr('src').replace(/(.+)(\.\w{3,4})$/, "$1" + settings['retina_part'] + "$2");
        $.ajax({
          url: new_image_src,
          type: "HEAD",
          success: function() {
            $(element).attr('src', new_image_src);
          }
        });
      });
    }
    return this;
  }
})(jQuery);

function icheck() {
  if ($(".icheck-me").length > 0) {
    $(".icheck-me").each(function() {
      var $el = $(this);
      var skin = ($el.attr('data-skin') !== undefined) ? "_" + $el.attr('data-skin') : "",
        color = ($el.attr('data-color') !== undefined) ? "-" + $el.attr('data-color') : "";

      var opt = {
        checkboxClass: 'icheckbox' + skin + color,
        radioClass: 'iradio' + skin + color,
        increaseArea: "10%"
      }

      $el.iCheck(opt);
    });
  }
}

function datepicker() {
  // datepicker
  if ($('.datepick').length > 0) {
    $('.datepick').datepicker({
      format: 'dd/mm/yyyy',
      todayHighlight: true,
      todayBtn: true,
      autoclose: true
    });
  }
}

function timepicker() {
  // timepicker
  if ($('.timepick').length > 0) {
    $('.timepick').timepicker({
      defaultTime: '9',
      minuteStep: 15,
      disableFocus: true,
      showInputs: true,
      template: false
    });
  }
}

var ready = function() {

  var mobile = false,
    tooltipOnlyForDesktop = true,
    notifyActivatedSelector = 'button-active';

  if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
    mobile = true;
  } else {
    $('a[rel=tooltip]').tooltip();
    $('i[rel=tooltip]').tooltip();
  }

  icheck();
  datepicker();
  timepicker();

  if ($("a.back").length > 0) {
    $('a.back').click(function(){
      parent.history.back();
      return false;
    });
  }

  if ($(".complexify-me").length > 0) {
    $(".complexify-me").complexify(function(valid, complexity) {
      if (complexity < 40) {
        $(this).parent().find(".progress .bar").removeClass("bar-green").addClass("bar-red");
      } else {
        $(this).parent().find(".progress .bar").addClass("bar-green").removeClass("bar-red");
      }

      $(this).parent().find(".progress .bar").width(Math.floor(complexity) + "%").html(Math.floor(complexity) + "%");
    });
  }

  // Round charts (easypie)
  if ($(".chart").length > 0) {
    $(".chart").each(function() {
      var color = "#881302",
        $el = $(this);
      var trackColor = $el.attr("data-trackcolor");
      if ($el.attr('data-color')) {
        color = $el.attr('data-color');
      } else {
        if (parseInt($el.attr("data-percent")) <= 25) {
          color = "#046114";
        } else if (parseInt($el.attr("data-percent")) > 25 && parseInt($el.attr("data-percent")) < 75) {
          color = "#dfc864";
        }
      }
      $el.easyPieChart({
        animate: 1000,
        barColor: color,
        lineWidth: 5,
        size: 80,
        lineCap: 'square',
        trackColor: trackColor
      });
    });
  }


  // Notifications
  $(".notify").click(function() {
    var $el = $(this);
    var title = $el.attr('data-notify-title'),
      message = $el.attr('data-notify-message'),
      time = $el.attr('data-notify-time'),
      sticky = $el.attr('data-notify-sticky'),
      overlay = $el.attr('data-notify-overlay');

    $.gritter.add({
      title: (typeof title !== 'undefined') ? title : 'Message - Head',
      text: (typeof message !== 'undefined') ? message : 'Body',
      image: (typeof image !== 'undefined') ? image : null,
      sticky: (typeof sticky !== 'undefined') ? sticky : false,
      time: (typeof time !== 'undefined') ? time : 3000
    });
  });

  // masked input
  if ($('.mask_date').length > 0) {
    $(".mask_date").mask("99/99/9999");
  }
  if ($('.mask_phone').length > 0) {
    $(".mask_phone").mask("(99) 99 999 999");
  }
  if ($('.mask_percent').length > 0) {
    $(".mask_percent").mask("9?9%");
  }

  // tag-input
  if ($(".tagsinput").length > 0) {
    $('.tagsinput').each(function(e) {
      if ($(this).hasClass("licensetypes")) {
        $(this).tagsInput({
          'height': 'auto',
          'width': 'auto',
          'defaultText': ''
        });
      } else {
        $(this).tagsInput({
          width: 'auto',
          height: 'auto',
          'defaultText' : 'Add a tag',
          'placeholderColor' : '#555555'
        });
      }
    });
  }

  // colorpicker
  if ($('.colorpick').length > 0) {
    $('.colorpick').colorpicker();
  }

  // uniform
  if ($('.uniform-me').length > 0) {
    $('.uniform-me').uniform({
      radioClass: 'uni-radio',
      buttonClass: 'uni-button'
    });
  }

  // Chosen (chosen)
  if ($('.chosen-select').length > 0) {
    $('.chosen-select').each(function() {
      var $el = $(this);
      var search = ($el.attr("data-nosearch") === "true") ? true : false,
        opt = {};
      if (search) opt.disable_search_threshold = 9999999;
      $el.chosen(opt);
    });
  }

  if ($(".select2").length > 0) {
    $(".select2").select2({
      minimumResultsForSearch: -1
    });
  }

  if ($(".select2-me").length > 0) {
    $(".select2-me").select2();
  }

  // multi-select
  if ($('.multiselect').length > 0) {
    $(".multiselect").each(function() {
      var $el = $(this);
      var selectableHeader = $el.attr('data-selectableheader'),
        selectionHeader = $el.attr('data-selectionheader');
      if (selectableHeader != undefined) {
        selectableHeader = "<div class='multi-custom-header'>" + selectableHeader + "</div>";
      }
      if (selectionHeader != undefined) {
        selectionHeader = "<div class='multi-custom-header'>" + selectionHeader + "</div>";
      }
      $el.multiSelect({
        selectionHeader: selectionHeader,
        selectableHeader: selectableHeader
      });
    });
  }

  // spinner
  if ($('.spinner').length > 0) {
    $('.spinner').spinner();
  }

  // dynatree
  if ($(".filetree").length > 0) {
    $(".filetree").each(function() {
      var $el = $(this),
        opt = {};
      opt.debugLevel = 0;
      if ($el.hasClass("filetree-callbacks")) {
        opt.onActivate = function(node) {
          $(".activeFolder").text(node.data.title);
          $(".additionalInformation").html("<ul style='margin-bottom:0;'><li>Key: " + node.data.key + "</li><li>is folder: " + node.data.isFolder + "</li></ul>");
        };
      }
      if ($el.hasClass("filetree-checkboxes")) {
        opt.checkbox = true;

        opt.onSelect = function(select, node) {
          var selNodes = node.tree.getSelectedNodes();
          var selKeys = $.map(selNodes, function(node) {
            return "[" + node.data.key + "]: '" + node.data.title + "'";
          });
          $(".checkboxSelect").text(selKeys.join(", "));
        };
      }

      $el.dynatree(opt);
    });
  }

  if ($(".colorbox-image").length > 0) {
    $(".colorbox-image").colorbox({
      maxWidth: "90%",
      maxHeight: "90%",
      rel: $(this).attr("rel")
    });
  }

  // Wizard
  if ($(".form-wizard").length > 0) {
    $(".form-wizard").formwizard({
      formPluginEnabled: true,
      validationEnabled: true,
      focusFirstInput: false,
      disableUIStyles: true,
      validationOptions: {
        errorElement: 'span',
        errorClass: 'help-block error',
        errorPlacement: function(error, element) {
          element.parents('.controls').append(error);
        },
        highlight: function(label) {
          $(label).closest('.control-group').removeClass('error success').addClass('error');
        },
        success: function(label) {
          label.addClass('valid').closest('.control-group').removeClass('error success').addClass('success');
        }
      },
      formOptions: {
        success: function(data) {
          alert("Response: \n\n" + data.say);
        },
        dataType: 'json',
        resetForm: true
      }
    });
  }

  // Validation
  if ($('.form-validate').length > 0) {
    $('.form-validate').each(function() {
      var id = $(this).attr('id');
      $("#" + id).validate({
        errorElement: 'span',
        errorClass: 'help-block error',
        highlight: function(label) {
          $(label).closest('.control-group').removeClass('error success').addClass('error');
        },
        success: function(label) {
          label.addClass('valid').closest('.control-group').removeClass('error success');
        }
      });
    });
    $.validator.addMethod('positiveNumber',
      function(value) {
        return Number(value) >= 0;
      }, 'Numbers only');
  }

  // dataTables
  if ($('.dataTable').length > 0) {
    $('.dataTable').each(function() {
      if (!$(this).hasClass("dataTable-custom")) {

        $(this).css("width", '100%');

        var columnSort = new Array;
        $(this).find('thead tr th').each(function(){
          if($(this).attr('data-orderable') == 'false') {
            columnSort.push({ "orderable": false });
          } else {
            columnSort.push({ "orderable": true });
          }
        });

        var opt = {
          pagingType: "full_numbers",
          language: {
            search: "<span>Search:</span> ",
            info: "Showing <span>_START_</span> to <span>_END_</span> of <span>_TOTAL_</span> entries",
            lengthMenu: "_MENU_ <span>entries per page</span>"
          },
          dom: "<'dataTables_resetBtn'>lfrtip",
          columns: columnSort,
          searchDelay: 350,
          deferRender: true
        };

        if($(this).attr('data-default-sort-column')) {
          if($(this).attr('data-default-sort-direction')) {
            var sort_direction = $(this).attr('data-default-sort-direction')
          } else {
            var sort_direction = "asc"
          }
          sort_column = $(this).attr('data-default-sort-column')
          opt.order = [[ sort_column, sort_direction]]
        }

        if ($(this).hasClass("dataTable-ajax")) {
          opt.processing = true;
          opt.serverSide = true;
          // opt.ajax = $(this).data('source');
          opt.ajax = {
            url: $(this).data('source'),
            data: function(d) {
              if ($("#show-all").length > 0) {
                var showAll = $("#show-all").is(":checked");
                d.showAll = showAll;
              }
              d.columns = null;
            }
          }
        }

        if ($(this).hasClass("dataTable-noheader")) {
          opt.searching = false;
          opt.lengthChange = false;
        }

        if ($(this).hasClass("dataTable-nofooter")) {
          opt.info = false;
          opt.paging = false;
        }

        if ($(this).hasClass("dataTable-scroll-x")) {
          opt.scrollX = "100%";
          opt.scrollCollapse = true;
        }

        if ($(this).hasClass("dataTable-colvis")) {
          opt.dom = "C" + opt.dom;
          opt.oColVis = {
            "buttonText": "Columns <i class='icon-angle-down'></i>",
            "iOverlayFade": 50,
            "sAlign": "right"
          };
        }

        if ($(this).hasClass('dataTable-tools') && !/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
          var colCount = 0;
          var colCountArray = [];
          $('.dataTable-tools tr:nth-child(1) td').each(function() {
            colCountArray.push(colCount++);
          });
          colCountArray.pop(); // Remove last column - Actions column

          opt.dom = "T" + opt.dom;
          opt.bDestroy = true
          opt.oTableTools = {
            "sSwfPath": "media/swf/copy_csv_xls_pdf.swf",
            "aButtons": [
              {
                "sExtends": "csv",
                "mColumns": "visible"
              },
              {
                "sExtends": "print"
              }
            ]
          };
        }


        if ($(this).hasClass("dataTable-popup")) {
          opt.statesave = false;
          $('.dataTables_filter input').attr("placeholder", "Search here...");
          $('.dataTables_filter').css({
            "float": "left",
            "margin-left": "10px"
          });
        }

        opt.stateSave = true;
        // opt.stateDuration = 0;

        opt.stateSaveCallback = function(settings, data) {
          localStorage.setItem('DataTables_Table'+location.pathname, JSON.stringify(data));
          // console.log(oSettings);
          // console.log(oData);
          // oSettings.sInstance = "Table";
          // oSettings.sTableId = "Table";
          // // localStorage.setItem('DataTables', JSON.stringify(oData));
          // resize_page();
        };

        opt.stateLoadCallback = function(oSettings) {
          return JSON.parse(localStorage.getItem('DataTables_Table'+location.pathname));
        };

        // opt.stateLoadParams = function (oSettings, oData) {
        //   oData.search = [];
        //   oData.order = [];
        //   oData.abVisCols = [];
        // };

        opt.initComplete = function(oSettings) {
          resize_page();
          $(".has-tooltip").tooltip();
          $(".has-popover").popover();
        };

        var table = $(this).DataTable(opt);

        table.on('draw.dt', function () {
          table.state.save();
        });

        $('.dataTables_filter input').attr("placeholder", "Search here...");

        $(".dataTables_length select").wrap("<div class='input-mini'></div>").chosen({
          disable_search_threshold: 9999999
        });

        $("#check_all").click(function(e) {
          $('input', table.fnGetNodes()).prop('checked', this.checked);
          // row().node(), rows().nodes(), cell().node()
        });

        table.draw();

        if ($("#show-all").length > 0) {
          $("#show-all").on("ifClicked", function(event) {
            setTimeout( function() {
              table.draw();
            }, 100);
          });
        }

        $(window).resize(function() {
          table.columns.adjust();
        });

        $("div.dataTables_resetBtn").html('<a href="#">Reset Filters</a>');

        $("div.dataTables_resetBtn").click(function() {
          table.state.clear();
          window.location.reload();
        });
      }
    });
  }

  // force correct width for chosen
  resize_chosen();

  // file_management
  if ($('.file-manager').length > 0) {
    $('.file-manager').elfinder({
      url: 'js/plugins/elfinder/php/connector.php'
    });
  }

  // slider
  if ($('.slider').length > 0) {
    $(".slider").each(function() {
      var $el = $(this);
      var min = parseInt($el.attr('data-min')),
        max = parseInt($el.attr('data-max')),
        step = parseInt($el.attr('data-step')),
        range = $el.attr('data-range'),
        rangestart = parseInt($el.attr('data-rangestart')),
        rangestop = parseInt($el.attr('data-rangestop'));

      var opt = {
        min: min,
        max: max,
        step: step,
        slide: function(event, ui) {
          $el.find('.amount').html(ui.value);
        }
      };

      if (range !== undefined) {
        opt.range = true;
        opt.values = [rangestart, rangestop];
        opt.slide = function(event, ui) {
          $el.find('.amount').html(ui.values[0] + " - " + ui.values[1]);
          $el.find(".amount_min").html(ui.values[0] + "$");
          $el.find(".amount_max").html(ui.values[1] + "$");
        };
      }

      $el.slider(opt);
      if (range !== undefined) {
        var val = $el.slider('values');
        $el.find('.amount').html(val[0] + ' - ' + val[1]);
        $el.find(".amount_min").html(val[0] + "$");
        $el.find(".amount_max").html(val[1] + "$");
      } else {
        $el.find('.amount').html($el.slider('value'));
      }
    });
  }

  if ($('.editor').length > 0) {
    var data = $('.editor');
    $.each(data, function(i) {
      CKEDITOR.replace(data[i].id, {
        language: "en",
        toolbar: [
          [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
          [ 'RemoveFormat' ],
          [ 'NumberedList', 'BulletedList' ],
          [ 'Outdent', 'Indent' ],
          [ 'Table' ],
          [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord'],
          [ 'Undo', 'Redo' ],
          [ 'Find', 'Replace' ],
          [ 'Scayt' ],
          [ 'Link', 'Unlink'],
          [ 'Source' ],
          [ 'ShowBlocks', 'Maximize' ]
        ]
      });

      CKEDITOR.on('instanceReady', resize_page);
      CKEDITOR.on('instanceLoaded', function(ev) {
        ev.editor.on('resize',function(reEvent){
          resize_page();
        });
      });
    });
  }

  if ($(".auto-textarea").length > 0) {
    $(".auto-textarea").each(function() {
      $(this).autosize();
    });
  }

  $(".retina-ready").retina("@2x");

  // Detect fullscreen web app
  if (("standalone" in window.navigator) && window.navigator.standalone) {
    var updateStatusBar = navigator.userAgent.match(/iP[ha][od].*OS 7/) &&
      parseInt(navigator.appVersion.match(/OS (\d)/)[1], 10) >= 7;
    if (updateStatusBar) {
      document.body.style.webkitTransform = 'translate3d(0, 20px, 0)';
    }
    $('body').addClass('mobile-app');
  }
};

$(document).ready(ready);
$(document).on('turbolinks:load  ', ready);

$(window).resize(function() {
  // chosen resize bug
  resize_chosen();
});

function resize_page() {
  var page_height = $("#main").height()
  $("#content").css("height", page_height + 50);
}

function resize_chosen() {
  $('.chzn-container').each(function() {
    var $el = $(this);
    $el.css('width', $el.parent().width() + 'px');
    $el.find(".chzn-drop").css('width', ($el.parent().width() - 2) + 'px');
    $el.find(".chzn-search input").css('width', ($el.parent().width() - 37) + 'px');
  });
}
