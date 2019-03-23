function saveDocument() {
    $.ajax({
        type: "POST",
        url: $('#edit-form').attr('action'),
        data: $('#edit').serialize(),
        success: () => {
            $("#lastUpdate").html(new Date().getTime())
        }
    });
}

var timeoutId;
if (document.getElementById("edit")) {
    document.getElementById("edit").addEventListener("input", (a) => {
        console.log("fuck me")
        clearTimeout(timeoutId);
        timeoutId = setTimeout(saveDocument, 4000)
    })
}

if ($("form#edit-form")) {
    $("form#edit-form").submit(function (e) {
        e.preventDefault();
    
        saveDocument();
    });
}

$(function() {
    $("textarea").autoResize();
});